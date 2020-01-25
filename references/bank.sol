/*Exercise III
Problem Description 

Write a smart contract called bank, which will hold and transact your money.

The smart contract should have:

Two storage variables: One address variable to store the address of an account owner and 
a uint variable to store the account balance.

A constructor that stores the value of the creator address as account owner (i.e., msg.sender).

A deposit function, which will update the user’s balance with the added deposit and return the user’s balance.

A withdraw function, which will deposit the withdrawn amount to the owner’s Ethereum account
 (note that an amount more than the balance cannot be withdrawn). The function should return the user’s balance.
*/

pragma solidity ^0.5.0;


contract Bank {
   
   
    address public owner;
    
    uint balance;

    // Constructor is "payable" so it can receive the initial funding of 30, 
    // required to reward the first 3 clients
    constructor() public payable {
        
        require(msg.value == 1 wei);
        owner = msg.sender;
    }
        
    function deposit() public payable returns (uint) {
        balance += msg.value;
        return balance;
    }

    function withdraw(uint withdrawAmount) public returns (uint remainingBal) {
        // Check enough balance available, otherwise just return balance
        if (withdrawAmount <= balance) {
            balance -= withdrawAmount;
            msg.sender.transfer(withdrawAmount);
        }
        return balance;
    }

}