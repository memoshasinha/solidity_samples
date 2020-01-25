pragma solidity ^0.5.0;


contract SumNaturalNumbers {

    function summation(uint n) public pure returns(uint) {
        uint sum;
        sum = 0;
        sum = n * (n+1) / 2;
        return sum;
    }
}