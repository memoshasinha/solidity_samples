pragma solidity ^0.5.0;


contract ModifierDemo {
    
    function modifiedSum(uint n) public returns(uint) {
        //add your modifier to the function declaration here
        uint sum;
        sum = 0;
        for (uint i = 1; i < n+1; i++) {
            sum = sum+i;
        }
        return sum;
    }

    modifier bigSums(uint n) {
        require(n > 10);
        _;
    }    
    
}