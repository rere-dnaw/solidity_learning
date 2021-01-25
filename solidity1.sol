pragma solidity 0.8.0; //assign the compiler version

//solidity is a "typed" language(int, uint, string, bool, address)
    //"address" type is an ETH address
    //"uint" type of int which can't be negative
    //deciaml type is NOT valid for solidity
    
//the function can be restricted by two key words: pure, view. If no key word then func is not restricted(e.g. can change state variable).

//buildin variable: msg.sender(contract calling address), msg.value(value in eth) 

contract HelloWorld {
    //global variable
    string message = "Hello World Global";
    
    //state variable
    string stateMsg;
    int number;
    int[] arrNum;
    
    //constructor like everywhere else
    constructor(string memory _message){
        stateMsg = _message;
    }
  
    function hello () public pure returns(string memory){
        return "Hello World";
    } //"pure" this func will not interract with any other parts of the smart contract (won't read/write/interract variable form outside of func)

    function helloGlobal () public returns(string memory){
        return message;
    } //notice that "pure" have to be removed to access a global variable
    
    function helloLocal () public pure returns(string memory){
        string memory message = "Hello World Local";
        return message;
    } //the local string variable require a memory allocation "string memory"
    
    function helloView () public view returns(string memory){
        return stateMsg;
    }//"view" allow to access a state variable, but it can't change the state variable
    
    function helloSender() public view returns(string memory){
        if(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4){
            return message;
        }
        else
        {
            return "Wrong number";
        }
    }
    
    //loop like in C#/javaScript
    function helloLoopWhile(int number) public pure returns(int){
        int i = 0;
        while(i < 10){
            number++;
            i++;
        }
        return number;
    }
    
    //loop like in C#/javaScript
    function helloLoopFor(int number) public pure returns(int){
        for(int i=0;i<10;i++){
            number++;
        }
        return number;
    }
    
    //getter
    function getNumber() public view returns(int){
        return number;
    }
    
    //setter
    function setNumber(int _number) public returns(int){
        number = _number;
    }
    
    function addArrNumber(int _number) public {
        arrNum.push(_number); //"push" can be used only for dynamic array
    }
    
    // array index is uint type
    function getArrNumber(uint _id) public view returns(int){
        return arrNum[_id];
    }
    
    function getArray() public view returns(int[] memory){
        return arrNum;
    }
    
    //like class
    struct Person{
        uint age;
        string name;
    }
    
    //array of objects
    Person[] people;
    
    function addPerson(uint _age, string memory _name) public {
        Person memory newPerson = Person(_age, _name); //custom object require memory allocation
        people.push(newPerson);
    }
    
        
    //can't return the object so the properties needs to be return
    function getPerson(uint _id) public view returns(uint, string memory){
        Person memory returnPerson = people[_id];
        return (returnPerson.age, returnPerson.name);
    }

}

contract Bank {
    
    //MAPPING (dictionary) mapping(keyType => valueType)name
    
    address owner;
    
    //indexed will allow to search for events raised for specified address. e.g. after sometime all events related to this address czn be found
    // only three parameters per event can be indexed
    event balanceAdded(uint amount, address indexed recipient); //defined event
    event balanceTransfer(address indexed fromAddress, address indexed toAddress, uint value);
    
    constructor(){
        owner = msg.sender;
    }
    
    //modifier can take arguments e.g. modifier onlyOwner (uint cost){ .......}
    modifier onlyOwner {
        require(msg.sender == owner, "No premission for this operation!"); // if reqire contition is not met, the function will be revert
        _; // _ means run the function. This line will be replaced with the function code
    }
    
    mapping(address => uint) balance;
    
    //modifier is before return or {
    function addBalance(uint _toAdd) public onlyOwner returns(uint) {
        
        balance[msg.sender] += _toAdd;
        emit balanceAdded(_toAdd, msg.sender);
        return balance[msg.sender];
    }
    
    function getBalance() public view returns(uint){
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

contract DataLocation {
    
    //Three difrent location for storing data in solidity
    // storage - pernamet data storage
    // memory - temporary data storage
    // calldata - similar to memory buy read-only
    
    //state variable
    uint data = 1000; //storage type. The storage type is set by default.
    string example = "Test";
    
    
    // Value data type is always stored in memory so doen't have to be specified. e.g. 
    function getString (string memory text) public pure returns(string memory){
        return text;
    }
    
    // Value data type is always stored in memory so doen't have to be specified.
    function getValue (uint value) public returns(uint){
        uint valueTmp = 0; //all variables defined under function are stored in memory by default like: uint memory valueTmp = 0;
        data = valueTmp;
        return value;
    }
    
    // this is example of calldata
    // function checkAddress(address calldata addressSelf) public returns(bool){
    //     if(addressSelf == msg.sender){
    //         return true;
    //     }else{
    //         return false;
    //     }
    // }
    
    
    // function setStringBad(string memory text) public{
    //     string memory newString = example; // this will NOT overwrite the "example" string because, the "newString" variable has memory parameter
    //     example = text;
    // }
    
    // function setStringGood(string memory text) public{
    //     string newString = example; // this will overwrite the "example" string
    //     example = text;
    // }
    
    
}
