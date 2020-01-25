pragma solidity >=0.5.99 <0.7.0;

/**
Functions specific to admin
 */
 

interface BankInterface{
    
    function addBank(bytes32 name, address bankAddress, bytes32 regNumber) external returns (uint);
    function removeBank(address bankAddress) external returns (uint);
    function addCustomers(bytes32 username, bytes32 customerData) external returns (uint);
    function modifyCustomer(bytes32 username, bytes32 customerData) external returns (uint);
    function viewCustomer(bytes32 username,bytes32 password) external view returns (bytes32);
    function upvoteCustomer(bytes32 username) external returns (uint);
    function removeCustomer(bytes32 username) external returns (uint);
    function addRequest(bytes32 username, bytes32 customerData) external returns (uint);
    function removeRequest(bytes32 username) external returns (uint);
    //function getBankDetails(address bankAddress) public returns(Bank memory);
    function setPassword(bytes32 username, bytes32 password) external returns(bool);
}


contract KYC is BankInterface{
    
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
    struct Bank{
        bytes32 name;
        address bankAddress;
        uint rating;
        uint kyc_count;
        bytes32 regNumber;
    }
    address adminAddress;
    // list of all Banks
    mapping (address => Bank) public banks;
    // list of all customers
    mapping (bytes32 => Customer) public customers;

    // list of all requests
    mapping (bytes32 => Request) public requests;
    
    //verified customer list
    mapping (bytes32 => Customer) public verified_customers;

    constructor () public{
        adminAddress = msg.sender;
    }

    /** Used by admin to add a bank to the KYC Contract. You need to verify if the user trying to call this function is admin or not.
        params
        name - name of Bank
        bankAddress - address of Bank
        regNumber - registration number of Bank
        returns flag stating the successful entry of bank to the contract. For now lets assume its uint
        Bool (True/False) or int (0/1)
    */
    function addBank(bytes32 name, address bankAddress, bytes32 regNumber) public validity(bankAddress) override returns (uint) {
        banks[bankAddress] = Bank(name, bankAddress, 0, 0,regNumber);
        return 1;
    }

    /** Used by admin to remove a bank from the KYC Contract.  You need to verify if the user trying to call this function is admin or not.
        params
        bankAddress - address of Bank
        regNumber - registration number of Bank
        returns flag stating the successful entry of bank to the contract. For now lets assume its uint
        Bool (True/False) or int (0/1)
    */
    function removeBank(address bankAddress) public validity(bankAddress) override returns (uint) {
        delete banks[bankAddress];
        return 1;
    }

    modifier validity(address senderAddress){
      require(isAdmin(senderAddress),"Sender not authorized admin");
      _;
    }

    function isAdmin (address senderAddress) public view returns (bool) {
        if(adminAddress == senderAddress)
            return true;
        else
            return false;
    }
    /**
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function addCustomers(bytes32 username, bytes32 customerData) public override returns (uint){
        if(customers[username].username == username )
            return 0;
        else
        {
            if(requests[username].isAllowed){
                customers[username] = Customer(username, customerData,1,1,msg.sender,"");
                return 1;
            }
            else
                return 0;
        }
    }
    /**
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function modifyCustomer(bytes32 username, bytes32 customerData) public override returns (uint){
        customers[username].customerData = customerData;
        return 1;
    }

    /** View customer from the customer list.
        params
        username - customer name
        return the hash of the customer data in string format.
    */
    function viewCustomer(bytes32 username, bytes32 password) public override view returns(bytes32){
        Customer memory cust = customers[username];
        if(cust.password == "")
            cust.password = "0";
        else
            cust.password = password;
	    return cust.customerData;
    }

    /** Upvote customer from the customer list.
        params
        username - customer name// list of all valid KYCs
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function upvoteCustomer(bytes32 username) public override returns (uint){
        Request memory request = requests[username];
        Customer memory cust;
        cust.username = request.username;
        cust.upvote = cust.upvote + 1;
        //The rating is calculated as the number of upvotes for the customer/total number of banks.
        //If rating is more than 0.5, then you can add the customer to the final_customer list. If the bank has already voted for the same customer before, reject the request.
        //uint total_number_of_banks = 0;
        verified_customers[username] = cust;
        return 1;
    }
    /** Remove the customer from the customer list.
        params
        username - customer name
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function removeCustomer(bytes32 username) public override returns(uint){
        delete customers[username];
        return 1;
    }

    /**
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        isAllowed - boolean value to specify if the request is added by a trusted bank or not. If a bank is not secure, then the IsAllowed is set to
        false for all the bank requests done by the bank. Thus making sure that other banks don’t access the untrusted information.
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function addRequest(bytes32 username, bytes32 customerData) public override returns (uint){
        //If the bank rating is less than or equal to 0.5 then assign IsAllowed to false. Else assign IsAllowed to true.
        bool isAllowed = true;
        uint rating = 100;
        uint afterCalc = rating * 5 / 1000;
        if(banks[msg.sender].rating <= afterCalc)
        requests[username] = Request(username, customerData,msg.sender,isAllowed);
        return 1;
    }

    /** Removes the requests from the requests list.
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function removeRequest(bytes32 username) public override returns (uint){
        delete requests[username];
        return 1;
    }


    /*Get Bank Details (Unique Identifier for the Bank) - This function is used to fetch the bank details.
        ◦ Parameters - Bank address is passed to the function.
        ◦ Return - The return type of this function will be of type Bank.
    */   
    function getBankDetails(address bankAddress) public returns(Bank memory){
        return new Bank(banks[bankAddress]);
    }
    
    function setPassword(bytes32 username, bytes32 password) public override returns(bool){
        log0(bytes32(customers[username].username));
        if(customers[username].username != username )//check this condition
            return false;
        else
        {
          customers[username].password == password;
          return true;
        }
    }
}


