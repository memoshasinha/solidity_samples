pragma solidity ^0.5.10;


contract Sum {
    function addition() public pure returns (uint) {
        uint256 a = 2;
        uint256 b = 3;
        uint256 c = a+b;
        return c;
    }
}
