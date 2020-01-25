/*Exercise I
Problem Description 

Create a smart contract to keep track of the rooms occupied in a hospital. The smart contract should have:

A struct called room with the room name as a bytes32 variable (note that the values in this would be stored as hex values), the name of the occupant as a string value and a boolean variable indicating if a room is free.

Note:

a. We are using bytes32 since Solidity does not yet allow passing an array of strings as an argument to the constructor.

b. Since you have a constructor here, which takes arguments, you will have to add the required arguments while deploying the contract.

 

A constructor that takes in an array of bytes32 as input, which will be the room names. The constructor will add these to an array of rooms and set occupant as none and occupied as false.

A function to assign a room to a patient. The function will take the room name and the patient’s name as input, and will return 'assigned' after assigning a room to a patient. If a room is already occupied, then the function should return 'room occupied'.

 */
 
pragma solidity ^0.5.0;


contract Hospital {
    struct Room{
        bytes32 name;
        bool occupied;
        string occupant;
    }
    Room[] public rooms;
    
    constructor (bytes32[] memory names) public{
        for(uint i=0; i<names.length;i++){
            rooms.push(Room({
                name:names[i],occupied:false,occupant:"none"
            }));
            
        }
    }
    function assignRoom(bytes32 roomName, string memory patientName) public returns(string memory){
        for(uint i=0;i<rooms.length;i++){
            if(rooms[i].name==roomName){
                if(rooms[i].occupied==true){
                    return "room occupied";
                }
                else{
                    rooms[i].occupant=patientName;
                    rooms[i].occupied=true;
                    return "assigned";
                }
                
            }
        }
    }
    

}