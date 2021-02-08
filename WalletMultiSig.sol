pragma solidity 0.8.1; //assign the compiler version
pragma abicoder v2; // if need to return struct from function


contract Events {
    event depositComplete(address indexed depositFrom, uint amount);
    event addOwnerComplete(address indexed added, address indexed addedBy);
    event selfDestructed(address contractAddress);
    event numberSigUpdated(uint, address indexed addedBy);
    event duplicatedUserError(address indexed added, address indexed addedBy);
    event transactionRequestCreated(address indexed addedBy, address indexed receiver, uint amount);
    event transctionSigned(address indexed signedBy, uint transactionId);
    event transactionComplete(address indexed reciver, uint amount, uint contractBalance);
}


contract Privileges {
    address contractCreator;
    address[] owners;

    modifier onlyCreator {
        require(msg.sender == contractCreator, "Only for contract creator. Access Denied!");
        _;
    }
    
    modifier onlyOwner{
        bool ownerFound = false;
        for(uint i=0 ; i<owners.length ; i++){
            if(msg.sender == owners[i]){
                ownerFound = true;
            }
        }
        require(ownerFound == true, "Only for wallet owners. Access Denied!");
        _; //how to create modifer with loop
    }
    

}

contract Destroyable is Privileges, Events{

    function close() internal onlyCreator { //onlyOwner is a custom modifier
        emit selfDestructed(contractCreator);
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
        bool exist;
    }

    mapping(uint => Transaction) transaction; //(transaction id : number of signatures)

    function deposit() public payable{
        uint oldBalance = contractBalance;
        contractBalance += msg.value;
        emit depositComplete(msg.sender, msg.value);
        
        assert(contractBalance - msg.value == oldBalance);
    }
    
    function requiredSigUpdate(uint _requiredSig) public onlyCreator {
        requiredSig = _requiredSig;
        emit numberSigUpdated(_requiredSig, msg.sender);
        
        assert(requiredSig == _requiredSig);
    }
    
    function addOwner(address _ownerAddress) public onlyCreator {
        for(uint i=0 ; i<owners.length ; i++){
            if(_ownerAddress == owners[i]){
                emit duplicatedUserError(_ownerAddress, msg.sender);
                require(_ownerAddress != owners[i], "Owner has been already added. Operation failed!");
            }
        }
        uint oldOwnersNumber = owners.length;
        owners.push(_ownerAddress);
        emit addOwnerComplete(_ownerAddress, msg.sender);
        
        assert(owners.length - 1 == oldOwnersNumber);
    }
    
    function transferRequest(address _receiver, uint _amount) public onlyOwner returns(uint){

        transaction[transactionId] = Transaction(_receiver, _amount, 0, true);
        emit transactionRequestCreated(msg.sender, _receiver, _amount);
        transactionId++;
        return transactionId - 1;
        
    }
    
    function transferSign(uint _transactionId) public onlyOwner {
        require(transaction[_transactionId].exist == true, "Provided transaction ID does not exist!");

        uint oldSignNumber = transaction[_transactionId].numberSigns;
        transaction[_transactionId].numberSigns += 1;
        emit transctionSigned(msg.sender, _transactionId);
        
        assert(oldSignNumber == transaction[_transactionId].numberSigns - 1);
        
        if(transaction[_transactionId].numberSigns >= requiredSig){
            makeTransaction(_transactionId);
        }
    }
    
    function makeTransaction(uint _transactionId) public payable onlyOwner returns(uint){
        payable(transaction[_transactionId].receiver).transfer(transaction[_transactionId].amount);
        require(transaction[_transactionId].exist == true, "Provided transaction ID does not exist!");
        require(transaction[_transactionId].numberSigns >= requiredSig, "The transaction needs to be signed!");
        require(contractBalance >= transaction[_transactionId].amount, "Balance not sufficient!");
        
        uint oldBalance = contractBalance;
        contractBalance -= transaction[_transactionId].amount;
        emit transactionComplete(transaction[_transactionId].receiver, transaction[_transactionId].amount, contractBalance);
        
        assert(oldBalance == contractBalance - transaction[_transactionId].amount);
        
        return contractBalance;
    }
    
    function getBalance() public onlyOwner returns(uint){
        return contractBalance;
    }

}




