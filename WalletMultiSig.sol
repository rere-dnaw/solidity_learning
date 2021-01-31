pragma solidity 0.8.1; //assign the compiler version
pragma abicoder v2; // if need to return struct from function


contract Events {
    event depositComplete(address indexed depositFrom, uint amount);
}


contract Privileges {
    address contractCreator;
    Users[] walletOwners;
    uint walletBalance;
    
    constructor(){
        contractCreator = msg.sender;
        walletBalance = 0;
    }
    
    struct Users {
        address userAddress;
        uint userBalance;
    }

    
    modifier onlyCreator {
        require(msg.sender == contractCreator, "Only for contract creator. Access Denied!");
        _;
    }
    
    modifier onlyOwner{
        if(walletOwners.length != 0){
            for(int i = 0; i < walletOwners.length; i++){
                walletBalance++;
            }

        }
        _;
    }
    

}

contract Destroyable is Privileges {
    
    function close() internal onlyCreator {
        selfdestruct(payable(contractCreator));
    }
}


contract WalletMultiSig is Privileges, Events{
    
    
    //function addCreatorWallet() private
    
    
    function deposit() public payable returns(uint){
        walletBalance += msg.value;
        emit depositComplete(msg.sender, msg.value);
        return walletBalance;
    }
    
    
   
       //return balance of the current contract
    function getContractBalance() public returns(uint){
        return address(this).balance;
    }
    
}


