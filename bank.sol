pragma solidity ^0.5.10;


//"0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb21","0xdD870fA1b7C4700F2BD7f44238821C26f7392148","0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb21"
//"0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb20","0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C","0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb20"


contract Admin{
   
   struct Bank{
        bytes32 name;
        address ethAddress;
        uint rating;
        uint kyc_count;
        bytes32 regNumber;
    }
    // mapping of all Banks
    mapping (address => Bank) public banks;
    //list of all banks
    address[] public bankList;
    address public adminAddress;
   
    constructor() public {
          adminAddress=msg.sender;
    }
   
    function getIndexAddress(address addr,address[] memory any) internal pure returns(int256){
        int256 indexValue = -1;
        for(uint i = 0; i < any.length;i++) {
            if(any[i] == addr)
            {
                indexValue = int256(i);
            }
        }
        return indexValue;
       
    }
   
    function getIndexBytes(bytes32 addr,bytes32[] memory any) internal pure returns(int256){
        int256 indexValue = -1;
        for(uint i = 0; i < any.length;i++) {
            if(any[i] == addr)
            {
                indexValue = int256(i);
            }
        }
        return indexValue;
       
    }
   
    /**
     * Function to check if the bankAlreadyAdded in the list of banks
    **/
   
    function bankAlreadyAdded(address bankAddress) private view returns(bool bankExists) {
        if(bankList.length == 0) return false;
        if(getIndexAddress(bankAddress, bankList) != -1) return true;
        else return false;
    }
   
    /**
     * Function to check the totalNumberOfBanks
     **/
   
    function getTotalNumberOfBanks() public view returns(uint totalNumberOfBanks) {
        return bankList.length;
    }

    /** Used by admin to add a bank to the KYC Contract. You need to verify if the user trying to call this function is admin or not.
        name - name of Bank
        bankAddress - address of Bank
        regNumber - registration number of Bank
        returns value “1” to determine the status of success or value “0” for the failure of the function
    */
    function addBank(bytes32 name, address bankAddress, bytes32 regNumber) public validity(msg.sender) returns (uint){
        if(bankAlreadyAdded(bankAddress)) return 0;
        banks[bankAddress] = Bank(name, bankAddress, 0, 0,regNumber);
        bankList.push(bankAddress);
        return 1;
   
    }
   
    /** Used by admin to remove a bank from the KYC Contract.  You need to verify if the user trying to call this function is admin or not.
        params
        bankAddress - address of Bank
        regNumber - registration number of Bank
        returns flag stating the successful removal of bank from the contract.
        returns value “1” to determine the status of success or value “0” for the failure of the function
   
   */
   function removeBank(address bankAddress) public validity(msg.sender) returns (uint) {
        if(!bankAlreadyAdded(bankAddress)) return 0;
        delete banks[bankAddress];
        int256 bankTobeDeleted = getIndexAddress(bankAddress, bankList);
        bankList[uint256(bankTobeDeleted)] = bankList[bankList.length - 1];
        bankList.pop();
        return 1;
       
    }
    modifier validity(address senderAddress){
      require(isAdmin(senderAddress),"Sender not authorized admin");
      _;
    }
   
    function isAdmin (address senderAddress) private view returns (bool) {
        if(senderAddress == adminAddress)
            return true;
        else
            return false;
    }
   
}



contract Banks is Admin{
    struct Request {
        bytes32 username;
        bytes32 customerData;
        address bankAddress;
        bool isAllowed;
    }
   
    struct Customer{
        bytes32 username;
        bytes32 customerData;
        uint rating;
        uint upvote;
        address bank;
        bytes32 password;
   
    }
   
    constructor() Admin() public {
       
    }
    
    mapping(address => bytes32) kycDoneBy;
    
    // list of all requests
    mapping (bytes32 => Request[]) public requests;
   
    // list of all customers
    mapping (bytes32 => Customer) public customers;
   
   // list of all customers
    mapping (bytes32 => Customer) public verifiedCustomers;
    //list of all customers
    bytes32[] public customerList;
   
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
        if(bankList.length == 0) return 0;
        if(banks[msg.sender].rating <= afterCalc){
            isAllowed = false;
        }
        requests[username][requests[username].length] = Request(username, customerData,address(this),isAllowed);
        return 1;
       
    }
   
    function getRequestIndex(bytes32 addr,Request[] memory any) internal pure returns(int256){
        int256 indexValue = -1;
        for(uint i=0; i < any.length;i++){
            if(any[i].username == addr)
            {
                indexValue = int256(i);
            }
        }
        return indexValue;
       
    }
    /** Removes the requests from the requests list.
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function removeRequest(bytes32 username) public returns (uint){
        int256 requestToRemove = getRequestIndex(username,requests[username]);
        if(requestToRemove == -1) return 0;
        else{
            requests[username][uint(requestToRemove)] = requests[username][requests[username].length - 1];
            requests[username].pop();
            return 1;
        }
    }
   
    /**
        params
        username - stores customer name
        customerData - stores hash of customer data as a string
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function addCustomers(bytes32 username, bytes32 customerData) public returns (uint){
        int256 requestIndex = getRequestIndex(username,requests[username]);
        if(getIndexBytes(username, customerList) != -1) return 0;
        else{
            if(requests[username][uint(requestIndex)].isAllowed){
                customers[username] = Customer(username, customerData,1,1,msg.sender,"");
                return 1;
            }
            else
                return 0;
            }
    }
    /** Remove the customer from the customer list.
        params
        username - customer name
        returns value “1” to determine the status of success or value “0” for the failure of the function.
    */
    function removeCustomer(bytes32 username) public returns(uint){
        int256 customerToRemove = getIndexBytes(username, customerList);
        if(customerToRemove == -1) return 0;
        else{
            delete customers[username];
            customerList[uint256(customerToRemove)] = customerList[customerList.length - 1];
            customerList.pop();
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
            if(cust.password == password){
                return cust.customerData;
            }
            else{
                //default value as suggested by TA
                return cust.username;
            }
    }
    function modifyCustomer(bytes32 username, bytes32 customerData) public returns(int){
        Customer storage cust = customers[username];
        require(cust.username != (bytes32(0)),"Customer not found");
        if(getIndexBytes(username,customerList) != -1) return 0;
        else{
            //Customer storage verifiedCustomer = verifiedCustomers[username];
            cust.customerData = customerData;
            return 1;
        }
    }
   
    
   function upvoteCustomer(bytes32 username) public returns(uint){
       Customer storage cust = customers[username];
       require(cust.username != bytes32(0),"Customer not found");
       if(getIndexBytes(username,customerList) != -1)
        return 0;
       else{
            require(kycDoneBy[msg.sender] !=username, "Bank already voted for customer");
            kycDoneBy[msg.sender] = username;
            cust.upvote += 1;
            if(getTotalNumberOfBanks() == 0) return 0;
            cust.rating = cust.upvote/getTotalNumberOfBanks();
            uint numerator = 100;
            uint afterCalc = numerator * 5/1000;
            if(cust.rating > afterCalc){
                verifiedCustomers[username] = cust;
            }
            return 1;
       }
   }
}
