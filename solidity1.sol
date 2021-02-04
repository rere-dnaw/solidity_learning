pragma solidity 0.8.1; //assign the compiler version
pragma abicoder v2; // if need to return struct from function


contract Events {
    event depositComplete(address indexed depositFrom, uint amount);
    event addOwnerComplete(address indexed added, address indexed addedBy);
    event selfDestructed(address contractAddress);
    event numberSigUpdated(uint, address indexed addedBy);
    event duplicatedUserError(address indexed added, address indexed addedBy);
    event transactionRequestCreated(address indexed addedBy, address indexed _receiver, uint _amount);
    event transferSigned(address indexed signedBy, uint indexed transferId, uint _amount);
    event transactionComplete(address indexed _reciver, uint _amount, uint _contractBalance);
    event contractDestroyed(address _contractOwner);
}

contract Privileges {
    address contractCreator;
    address[] owners;
   
    modifier onlyCreator {
        require(msg.sender == contractCreator, "Only for contract creator. Access Denied!");
        _;
    }
    
    modifier onlyOwner{
        bool found = false;
        for(uint i=0 ; i<owners.length ; i++){
            if(msg.sender == owners[i]){
                found = true;
            }
        }
        
        require(found == true, "Only for wallet owner. Access Denied!");

        _;
    }
    
}

contract Destroyable is Privileges{

    function close() internal onlyCreator { //onlyOwner is a custom modifier
        selfdestruct(payable(contractCreator));
    }
}


contract WalletMultiSig is Privileges, Events{
    
    uint requiredSig;
    uint contractBalance;
    uint transactionId;
    
    constructor(){
        requiredSig = 2;
        contractBalance = 0;
        transactionId = 0;
        contractCreator = msg.sender;
    }
    
    struct Transaction {
        address receiver;
        uint amount;
        uint numberSigns;
    }

    mapping(uint => Transaction) transaction; //(transaction id : number of signatures)

    function deposit() public payable returns(uint){
        contractBalance += msg.value;
        emit depositComplete(msg.sender, msg.value);
        return contractBalance;
    }
    
    function requiredSigUpdate(uint _requiredSig) public onlyCreator {
        requiredSig = _requiredSig;
        emit numberSigUpdated(_requiredSig, msg.sender);
    }
    
    function addOwner(address _ownerAddress) public onlyCreator {
        for(uint i=0 ; i<owners.length ; i++){
            if(_ownerAddress == owners[i]){
                emit duplicatedUserError(_ownerAddress, msg.sender);
                require(_ownerAddress != owners[i], "Owner has been already added. Operation failed!");
            }
        }
        owners.push(_ownerAddress);
        emit addOwnerComplete(_ownerAddress, msg.sender);
    }
    
    function transferRequest(address _receiver, uint _amount) public onlyOwner returns(uint){
        transaction[transactionId] = Transaction(_receiver, _amount, 0);
        emit transactionRequestCreated(msg.sender, _receiver, _amount);
        transactionId++;

        return transactionId - 1;
    }
    
    function signTransaction(uint _transactionId) public onlyOwner returns(bool){
        transaction[_transactionId].numberSigns++;
        emit transferSigned(msg.sender, _transactionId, transaction[_transactionId].amount);
        if(transaction[_transactionId].numberSigns >= requiredSig){
            makeTransaction(_transactionId);
        }
        return true;
    }
    
    function makeTransaction(uint _transactionId) private returns(uint){
        payable(transaction[_transactionId].receiver).transfer(transaction[_transactionId].amount);
        require(contractBalance >= transaction[_transactionId].amount, "Balance not sufficient!");
        contractBalance -= transaction[_transactionId].amount;
        emit transactionComplete(transaction[_transactionId].receiver, transaction[_transactionId].amount, contractBalance);
        return contractBalance;
    }
    
    function getBalance() public onlyOwner returns(uint){
        return contractBalance;
    }
    
}
