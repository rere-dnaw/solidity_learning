pragma solidity 0.8.0; //assign the compiler version

//solidity is a "typed" language(int, uint, string, bool, address)
    //"address" type is an ETH address
    //"uint" type of int which can't be negative
    //deciaml type is NOT valid for solidity
    
//the function can be restricted by two key words: pure, view. If no key word  then func is not restricted.

//build in variable: msg.sender(contract calling address), msg.value(value in eth) 

contract HelloWorld {
    //global variable
    string message = "Hello World Global";
    
    //state variable
    string stateMsg;
    
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
    
}
