pragma solidity 0.8.1;


interface GovernmentInterface{
    function addTransaction(address _from, address _to, uint _amount) external payable;
}



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

    GovernmentInterface governmentInstance = GovernmentInterface(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);

    event depositComplete(address indexed _depositTo, uint amount); //defined event
    event withdrawComplete(address indexed fromAddress, uint amount);
    
    mapping(address => uint) balance;
    
    function deposit() public payable returns(uint) {
        balance[msg.sender] += msg.value;
        emit depositComplete(msg.sender, balance[msg.sender]);
        return balance[msg.sender];
    }
    
    function withdraw(uint _amount) public onlyOwner returns(uint){
        payable(msg.sender).transfer(_amount);
        require(balance[msg.sender] >= _amount, "Balance not suffcient!");
        balance[msg.sender] -= _amount;
        emit withdrawComplete(msg.sender, _amount);
        return balance[msg.sender];
    }
 
    
    function getBalance() public view returns(uint){
        return balance[msg.sender];
    }

    function transfer(address _recipient, uint amount) public {
        //check balance of msg.sender
        
        require(balance[msg.sender] >= amount, "Balance not sufficient!");
        require(msg.sender != _recipient, "Why are you doing that?");
        
        uint previousBalance = balance[msg.sender];
        
        governmentInstance.addTransaction{value: 1 gwei}(msg.sender, _recipient, amount);
        
        //gwei = 10^9
        //ether = 10^18
        
        _transfer(msg.sender, _recipient, amount);
        //emit balanceTransfer(msg.sender, _recipient, amount);
        
        
        assert(balance[msg.sender] == previousBalance - amount); //test
        
    }
    
    // _transfer - underscore is a naming convension for a private function
    function _transfer (address from, address to, uint amount) private{
        balance[from] -= amount;
        balance[to] += amount;
    }
}
