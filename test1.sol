pragma solidity ^0.5.10;


/**
Functions specific to admin
 */
 
//"0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb20","0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C","0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb20"


contract Bank{
       
   
    bytes32 name;
    address ethAddress;
    uint rating;
    uint kycCount;
    bytes32 regNumber;
    
    constructor(bytes32 _name, address _ethAddress, uint _rating, uint _kycCount, bytes32 _regNumber) public{
        name = _name;
        ethAddress = _ethAddress;
        rating = _rating;
        kycCount = _kycCount;
        regNumber = _regNumber;
    }
    
    
    
}




contract KYC is Admin{
    
    struct Customer{
        bytes32 username;
        bytes32 customerData;
        uint rating;
        uint upvote;
        address bank;
    	bytes32 password;
    
    }
    struct Request {
        bytes32 username;
        bytes32 customerData;
        address bankAddress;
        bool isAllowed;
    }
    
    constructor() Admin() public{
       
    }
  
    // list of all customers
    mapping (bytes32 => Customer) public customers;
    
    //list of all customers
    bytes32[] private customerList;
    
    // list of all requests
    mapping (bytes32 => Request[]) public requests;
    //list of all requests
    bytes32[] private requestList;
    
    //verified customer list
    mapping (bytes32 => Customer) public verified_customers;
    
    /**
        params
        username - customer name
        customerData - stores hash of customer data as a string
        isAllowed - boolean value to specify if the request is added by a trusted bank or not. If a bank is not secure, then the IsAllowed is set to
        false for all the bank requests done by the bank. Thus making sure that other banks don’t access the untrusted information.
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function addRequest(bytes32 username, bytes32 customerData) public returns (uint){
        //If the bank rating is less than or equal to 0.5 then assign IsAllowed to false. Else assign IsAllowed to true.
        bool isAllowed = true;
        uint rating = 100;
        uint afterCalc = rating * 5 / 1000;
        Bank bnk = banks[msg.sender];
        // Bank addRequestBy = getBankDetails(msg.sender);
        // if(addRequestBy.rating <= afterCalc){
        //     isAllowed = false;
        //     requests[username] = Request(username, customerData,msg.sender,isAllowed);
        //     requestList.push(username);
        //     return 0;
        // }
        // else{
        //     requests[username] = Request(username, customerData,msg.sender,isAllowed);
        //     return 1;
        //}
        return 1;
        
    }
     /** Removes the requests from the requests list.
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function removeRequest(bytes32 username) public returns (uint){
        int256 requestToRemove = getIndexBytes(username, requestList);
        if(requestToRemove == -1) return 0;
        else{
            delete requests[username];
            requestList[uint256(requestToRemove)] = requestList[requestList.length - 1];
            requestList.pop();
            return 1;
        }
    }
    
    

    /** View customer from the customer list.
        params
        username - customer name
        return the hash of the customer data in string format.
    */
    function viewCustomer(bytes32 username, bytes32 password) public view returns(bytes32){
        Customer memory cust = customers[username];
        if(cust.password == 0 )
            return cust.customerData;
        else{
            if(cust.password == password){
                return cust.customerData;
            }
            else{
                //default value as suggested by TA
                return cust.username;
            
            }
        }
	    
    }

  
    /**function to set password
     * 
     **/
    function setPassword(bytes32 username, bytes32 password) public view returns(bool){
        if(customers[username].username != username )//check this condition
            return false;
        else
        {
          customers[username].password == password;
          return true;
        }
    }
    
    
   
}


