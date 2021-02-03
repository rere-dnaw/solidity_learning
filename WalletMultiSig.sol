pragma solidity 0.8.1; //assign the compiler version
pragma abicoder v2; // if need to return struct from function


contract Events {
    event depositComplete(address indexed depositFrom, uint amount);
    event addOwnerComplete(address indexed added, address indexed addedBy);
    event selfDestructed(address contractAddress);
    event numberSigUpdated(uint, address indexed addedBy);
    event duplicatedUserError(address indexed added, address indexed addedBy);
    event transactionRequestCreated(address indexed addedBy, address indexed receiver, uint amount);
}


contract Privileges {
    address contractCreator;
    address[] owners;
    //address[] owners;
    // Users[] walletOwners;
    // uint walletBalance;
    
    // constructor(){
    //     contractCreator = msg.sender;
    //     walletBalance = 0;
    // }
    
    // struct Users {
    //     address userAddress;
    //     uint userBalance;
    // }

    
    modifier onlyCreator {
        require(msg.sender == contractCreator, "Only for contract creator. Access Denied!");
        _;
    }
    
    modifier onlyOwner{
        for(uint i=0 ; i<owners.length ; i++){
            if(msg.sender == owners[i]){
                
            }
        }
        _; //how to create modifer with loop
    }
    

}

// contract Destroyable is Privileges {
    
//     function close() internal onlyCreator {
//         emit selfDestructed(contractCreator);
//         selfdestruct(payable(owner));
//     }
// }


contract WalletMultiSig is Privileges, Events{
    
    uint requiredSig;
    uint contractBalance;
    uint transactionId;
    
    constructor(){
        requiredSig = 2;
        contractBalance = 0;
        transactionId = 0;
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
    
    function requiredSigUpdate(uint _requiredSig) private onlyCreator {
        requiredSig = _requiredSig;
        emit numberSigUpdated(_requiredSig, msg.sender);
    }
    
    function addOwner(address _ownerAddress) private onlyCreator {
        for(uint i=0 ; i<owners.length ; i++){
            if(_ownerAddress == owners[i]){
                emit duplicatedUserError(_ownerAddress, msg.sender);
                require(_ownerAddress != owners[i], "Owner has been already added. Operation failed!");
            }
        }
        owners.push(_ownerAddress);
        emit addOwnerComplete(_ownerAddress, msg.sender);
    }
    
    function transferRequest(address _receiver, uint _amount) private returns(uint){

        for(uint i=0 ; i<owners.length ; i++){
            if(msg.sender == owners[i]){
                transaction[transactionId] = Transaction(_receiver, _amount, 0);
                emit transactionRequestCreated(msg.sender, _receiver, _amount);
                transactionId++;
                return transactionId - 1;
            }
        }
        transaction[transactionId] = Transaction(_receiver, _amount, 0);
        
    }
    
    //function transferApprove()
    
}




