pragma solidity ^0.5.10;


contract KycVerificationPhase1{

    struct Customer{
        string username;
        string customerData;
        uint upvote;
        address bank;
	    string password;

    }
    struct Bank{
        string name;
        address ethAddress;
        string regNumber;
    }

    struct Request {
        string username;
        string customerData;
        address bankAddress;
    }

    // list of all customers
    Customer[] public allCustomers;

    // list of all Banks/Organisations
    Bank[] public allBanks;

    // list of all requests
    Request[] public allRequests;

    // list of all valid KYCs
    Request[] public validKYCs;

    /**
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        Function is made payable as banks need to provide some currency to start of the KYC process
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function addRequest(string memory username, string memory customerData) public payable returns (uint){
        uint allRequestsLen = allRequests.length;
        for(uint i = 0; i < allRequestsLen;i++) {
            if(stringsEqual(allRequests[i].username, username) && (stringsEqual(allRequests[i].customerData,customerData)))
            {
                return 1;
            }
           
        }
        allRequests.length ++;
        allRequests[allRequests.length - 1] = Request(username, customerData, msg.sender);
        return 1;
    }

    /** Removes the requests from the requests list.
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function removeRequest(string memory username) public payable returns (uint){
        for(uint i = 0; i < allCustomers.length; ++ i) {
        	if(stringsEqual(allRequests[i].username, username)) {
        	    allRequests[i] = allRequests[allRequests.length - 1];
        	    allRequests.pop();
        	return 0;
        	}
        }
        	// throw error if uname not found
        return 1;
    }
    /**
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function addCustomer(string memory username, string memory customerData) public payable returns (uint){
        uint allCustomersLen = allCustomers.length;
        for(uint i = 0; i < allCustomersLen;i++) {
            if(stringsEqual(allCustomers[i].username, username) && (stringsEqual(allCustomers[i].customerData,customerData)))
            {
                return 1;
            }
           
        }
        allCustomers.length ++;
        allCustomers[allCustomers.length - 1] = Customer(username, customerData,0,msg.sender,"");
        return 1;
    }

    /**
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function modifyCustomer(string memory username, string memory customerData) public payable returns (uint){
        for(uint i = 0; i < allCustomers.length; i++) {
        	if(stringsEqual(allCustomers[i].username, username)) {
        	allCustomers[i].customerData = customerData;
        	allCustomers[i].bank = msg.sender;
        	return 0;
        	}
        }
        	// throw error if uname not found
        return 1;
    }

    /** View customer from the customer list.
        params
        username - customer name
        return the hash of the customer data in string format.
    */
    function viewCustomer(string memory username) public payable returns (string memory){
        for(uint i = 0; i < allCustomers.length; ++ i) {
        	if(stringsEqual(allCustomers[i].username, username)) {
        	return allCustomers[i].customerData;
            }
        }
	return "Customer not found in database!";
    }

    /** Upvote customer from the customer list.
        params
        username - customer name
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function upvoteCustomer(string memory username) public payable returns (uint){
        for(uint i = 0; i < allCustomers.length; i++) {
        	if(stringsEqual(allCustomers[i].username, username)) {
            	allCustomers[i].upvote++;
            	return 0;
        	}
        }
        	// throw error if uname not found
        return 1;
    }
    /** Remove the customer from the customer list.
        params
        username - customer name
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function removeCustomer(string memory username) public payable returns (uint){
        for(uint i = 0; i < allCustomers.length; ++ i) {
        	if(stringsEqual(allCustomers[i].username, username)) {
        	    allCustomers[i] = allCustomers[allCustomers.length - 1];
        	    allCustomers.pop();
        	return 0;
        	}
        }
        	// throw error if uname not found
        return 1;
    }
    
        // function to compare two string value
    // This is an internal fucntion to compare string values
    // @Params - String a and String b are passed as Parameters
    // @return - This function returns true if strings are matched and false if the strings are not matching
    
    
    function stringsEqual(string storage _a, string memory _b) internal view returns (bool) {
    	bytes storage a = bytes(_a);
    	bytes memory b = bytes(_b);
    	if (a.length != b.length)
    	return false;
    	// @todo unroll this loop
    	for (uint i = 0; i < a.length; i ++)
    	{
    	if (a[i] != b[i])
    	return false;
    	}
    	return true;
    }
    
        
}