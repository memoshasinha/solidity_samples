/*Exercise II
Problem Description 

Write a smart contract to conduct a fair election among candidates. We will be using bytes32 variables as candidate names.

The smart contract should have:

An array of uint to bytes32 mapping to store the votes received by each candidate.

A constructor that takes the names of candidates as input and stores them.

A function to vote for a candidate that takes the candidate's name as input.

A function that returns the votes received by a candidate and takes candidate name as input.

Note: Before processing voting or counting of total votes, make sure that a candidate is valid [Hint: Write a function to check candidate validity, and use require() or a modifier to make sure the candidate is valid before executing the function.]
"0x0000000000000000000000000000000000000000000000000000000074657374",
"0x0000000000000000000000000000000000000000000000000000000074657375",
"0x0000000000000000000000000000000000000000000000000000000074657376",
"0x0000000000000000000000000000000000000000000000000000000074657377",
"0x0000000000000000000000000000000000000000000000000000000074657378",
"0x0000000000000000000000000000000000000000000000000000000074657379"

*/
pragma solidity ^0.5.0;
// We have to specify what version of compiler this code will compile with

contract Voting {
  
  mapping (bytes32 => uint8) public totalVotes;
  
  bytes32[] public candidates;

  constructor(bytes32[] memory candidateNames) public {
    candidates = candidateNames;
  }

  function totalVotesFor(bytes32 candidate) validity(candidate) public returns (uint8) {
    return totalVotes[candidate];
  }

  function voteForCandidate(bytes32 candidate) validity(candidate) public {
    totalVotes[candidate] += 1;
  }
    
  modifier validity(bytes32 candidate){
      require(isValidCandidate(candidate));
      _;
  }
  
  function isValidCandidate (bytes32 candidate) public returns (bool) {
    for(uint i = 0; i < candidates.length; i++) {
      if (candidates[i] == candidate) {
        return true;
      }
    }
    return false;
  }

}