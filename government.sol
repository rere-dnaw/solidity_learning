pragma solidity 0.8.1;

contract Government {
    
    event transactionComplete(address indexed from, address indexed to, uint amount, uint txid);
    event transactionGet(address indexed from, address indexed to, uint amount, uint txid);
    
    struct Transaction{
        address from;
        address to;
        uint amount;
        uint txid;
    }
    
    Transaction[] transactionLog;
    
    // external must be executed by another contract
    function addTransaction(address _from, address _to, uint _amount) external payable {
        //Transaction memory _transaction = Transaction(_from, _to, _amount, transactionLog.length);
        transactionLog.push(Transaction(_from, _to, _amount, transactionLog.length));
        emit transactionComplete(_from, _to, _amount, transactionLog.length);
    }
    
    function getTransaction(uint _txid) public returns(address, address, uint, uint){
        emit transactionGet(transactionLog[_txid].from, transactionLog[_txid].to, transactionLog[_txid].amount, transactionLog[_txid].txid);
        return (transactionLog[_txid].from, transactionLog[_txid].to, transactionLog[_txid].amount, transactionLog[_txid].txid);
    }
    
    //return balance of the current contract
    function getContractBalance() public returns(uint){
        return address(this).balance;
    }
}
