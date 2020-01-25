pragma solidity ^0.5.10;


contract Test {
    uint amount;

    address sendersaddress;
    
    function getPayment() public {   
        sendersaddress = msg.sender;
        Amount = msg.value;         
    }
    uint total = 0;
    function f(uint a, uint b) public view returns (uint) {
        	total = a * (b + 42) + now;
        return total;
    }
}
