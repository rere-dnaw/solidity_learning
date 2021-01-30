pragma solidity 0.8.1;

contract Ownable {
    address owner;
    
    //modifier can take arguments e.g. modifier onlyOwner (uint cost){ .......}
    modifier onlyOwner {
        require(msg.sender == owner, "No premission for this operation!"); // if reqire contition is not met, the function will be revert
        _; // _ means run the function. This line will be replaced with the function code
    }
        
    constructor(){
        owner = msg.sender;
    }
    
}

contract Destroyable is Ownable{

    function close() internal onlyOwner { //onlyOwner is a custom modifier
        selfdestruct(payable(owner));
    }
}


contract Bank is Ownable {

    event balanceAdded(uint amount, address indexed recipient); //defined event
    event balanceTransfer(address indexed fromAddress, address indexed toAddress, uint value);
    
    mapping(address => uint) balance;
    
    //modifier is before return or {
    function addBalance(uint _toAdd) public onlyOwner returns(uint) {
        
        balance[msg.sender] += _toAdd;
        emit balanceAdded(_toAdd, msg.sender);
        return balance[msg.sender];
    }
    
    function getBalance() public view onlyOwner returns(uint){
        return balance[msg.sender];
    }
    
    // there exist 4 types of visibilities
    // public - anyone can execute the function
    // private - only within the contract, remix(IDE) will not be able to execute the contract
    // internal - like private but allow to execute function for contracts deriving from it
    // external - only be able to execute from another contract of service. The contracts on ETH blockchain can interact between each other. 
    
    function transfer(address _recipient, uint amount) public {
        //check balance of msg.sender
        
        require(balance[msg.sender] >= amount, "Balance not sufficient!");
        require(msg.sender != _recipient, "Why are you doing that?");
        
        uint previousBalance = balance[msg.sender];
        
        _transfer(msg.sender, _recipient, amount);
        emit balanceTransfer(msg.sender, _recipient, amount);
        
        assert(balance[msg.sender] == previousBalance - amount); //test
        
    }
    
    // _transfer - underscore is a naming convension for a private function
    function _transfer (address from, address to, uint amount) private{
        balance[from] -= amount;
        balance[to] += amount;
    }
}



