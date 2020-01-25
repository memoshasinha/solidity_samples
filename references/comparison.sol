pragma solidity >=0.4.22 <0.6.0;


contract Comparsion {
    function comparison(uint a, uint b) public {
        uint c;
        if (a > b) {
            c = a;
        }else {
            c = b;
        }
        log1(
            bytes32(c),
            bytes32(uint256(msg.sender))
        );
    }
}