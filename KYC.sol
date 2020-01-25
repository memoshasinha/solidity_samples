
pragma solidity ^0.5.10;

//"0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb21","0xdD870fA1b7C4700F2BD7f44238821C26f7392148","0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb21"
//"0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb20","0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C","0x50cb9fe53daa9737b786ab3646f04d0150dc50ef4e75f59509d83667ad5adb20"


contract Admin{
    uint256 constant UINT_NULL = 0;
    bytes32 constant BYTES_NULL = "";
   struct Bank{
        bytes32 name;
        address ethAddress;
        uint rating;
        uint kyc_count;
        bytes32 regNumber;
    }
    /*
    Mapping a bank's address to the Bank Struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(address => Bank) banks;
    address[] bankAddresses;
    address public adminAddress;
    constructor() public {
          adminAddress = msg.sender;
    }

    /**
     * find the index in memory array
     * @param addr address to be searched
     * @param any list of memory
     * @return internal pure returns(int256)
     */
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
    /**
     * find index in bytes32 array
     * @param addr address to be searched
     * @param any list of memory
     * @return internal pure returns(int256)
     */
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
     * check if bank is added
     * @param bankAddress address of bank
     * @return private view returns(bool bankExists)
     */
    function bankAlreadyAdded(address bankAddress) private view returns(bool bankExists) {
        if(bankAddresses.length == 0) return false;
        if(getIndexAddress(bankAddress, bankAddresses) != -1) return true;
        else return false;
    }
    /**
     * total number of banks
     * @return public view returns(uint totalNumberOfBanks)
     */
    function getTotalNumberOfBanks() public view returns(uint totalNumberOfBanks) {
        return bankAddresses.length;
    }
    /**
     * Add bank
     * @param name bank name
     * @param bankAddress  bank address
     * @param regNumber registration number
     * @return public validity(msg.sender) returns (uint)
     */
    function addBank(bytes32 name, address bankAddress, bytes32 regNumber) public validity(msg.sender) returns (uint){
        if(bankAlreadyAdded(bankAddress)) return 0;
        banks[bankAddress] = Bank(name, bankAddress, 0, 0,regNumber);
        bankAddresses.push(bankAddress);
        return 1;
    }
   /**
    * Remove bank from list
    * @param bankAddress address of bank
    * @return public validity(msg.sender) returns (uint)
    */
   function removeBank(address bankAddress) public validity(msg.sender) returns (uint) {
        if(!bankAlreadyAdded(bankAddress)) return 0;
        delete banks[bankAddress];
        int256 bankTobeDeleted = getIndexAddress(bankAddress, bankAddresses);
        bankAddresses[uint256(bankTobeDeleted)] = bankAddresses[bankAddresses.length - 1];
        bankAddresses.pop();
        return 1;
    }
    /**
     * modifier
     */

    modifier validity(address senderAddress){
      require(isAdmin(senderAddress),"Sender not authorized admin");
      _;
    }
    /**
     * check if address is admin
     * @param senderAddress sender address
     * @return private view returns (bool)
     */
    function isAdmin (address senderAddress) private view returns (bool) {
        if(senderAddress == adminAddress)
            return true;
        else
            return false;
    }
}
contract Banks is Admin{
    struct KYCRequest {
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
    /// constructor
    constructor() Admin() public {
    }
    /*
    Mapping a customer's Data Hash to KYC request captured for that customer.
    This mapping is used to keep track of every kycRequest initiated for every customer by a bank.
     */
    mapping(bytes32 => KYCRequest) kycRequests;
    bytes32[] customerDataList;
    mapping (bytes32 => Customer) public customers;
    bytes32[] public customerList;
    mapping (bytes32 => Customer) public verifiedCustomers;
    bytes32[] public finalCustomerList;
    mapping (bytes32 => address) public upvotedFor;
    /*
    Mapping a customer's user name with a bank's address
    This mapping is used to keep track of every upvote given by a bank to a customer
     */
    mapping(bytes32 => mapping(address => uint256)) customerUpvotes;

    /*
    Mapping a bank's address name with a another bank's address
    This mapping is used to keep track of every upvote given by a bank to a another bank
     */
    mapping(address => mapping(address => uint256)) bankUpvotes;
    /**
     * Add request
     * @param _username customer name
     * @param _customerData customer data
     * @return public returns (uint)
     */
    function addRequest(bytes32 _username, bytes32 _customerData) public returns (uint){
        // Check that the user's KYC has not been done before, the Bank is a valid bank and it is allowed to perform KYC.
        require(kycRequests[_customerData].bankAddress == address(0), "This user already has a KYC request with same data in process.");
        //If the bank rating is less than or equal to 0.5 then assign IsAllowed to false. Else assign IsAllowed to true.
        bool isAllowed = true;
        uint rating = 100;
        uint afterCalc = rating * 5 / 1000;
        if(bankAddresses.length == 0) return 0;
        if(banks[msg.sender].rating <= afterCalc){
            isAllowed = false;
        }
        kycRequests[_customerData].customerData = _customerData;
        kycRequests[_customerData].username = _username;
        kycRequests[_customerData].bankAddress = msg.sender;
        kycRequests[_customerData].isAllowed = isAllowed;
        customerDataList.push(_customerData);
        return 1;
    }
    /**
     * Remove request
     * @param _username customer name
     * @return public returns (uint)
     */
    function removeRequest(bytes32 _username) public returns (uint){
        uint8 result = 0;
        for (uint256 j = 0; j < customerDataList.length; j++) {
            if (kycRequests[customerDataList[j]].username == _username) {
                delete kycRequests[customerDataList[j]];
                for(uint k = j+1;k < customerDataList.length;k++)
                {
                    customerDataList[k-1] = customerDataList[k];
                }
                customerDataList.length --;
                result = 1;
            }
        }
        return result; // 0 is returned if no request with the input username is found.
    }
    /**
     * add a customer to the customer list.
     * @param _userName customer name
     * @param _customerData customer data
     * @return public returns (uint)
     */
    function addCustomers(bytes32 _userName, bytes32 _customerData) public returns (uint){
        require(customers[_userName].bank == address(0),
        "Customer already added, call modifyCustomer to edit the customer data");
        customers[_userName].username = _userName;
        customers[_userName].customerData = _customerData;
        customers[_userName].bank = msg.sender;
        customers[_userName].upvote = 0;
        customerList.push(_userName);
        return 1;
    }
     /**
     * Remove a customer
     * @param username customer name
     * @return public returns(uint)
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
   /**
     * view details of a customer
     * @param username customer name
     * @param password customer password
     * @return public view returns(bytes32)
     */
    function viewCustomer(bytes32 username, bytes32 password) public view returns(bytes32){
        Customer memory cust = customers[username];
            if(cust.password == bytes32(0) && password == "0"){
                return cust.customerData;
            }
            else{
                //default value as suggested by TA
                return BYTES_NULL;
            }
    }
    /**
     * modify a customer's data
     * Only applicable for the customers whose request have been validated and present in the customer list. If the user is present in the final customer
     * list then remove it from the final list and change the upvotes and rating component of the customer in customer list to "0".
     * Remove all the previous upvotes for the customer. Hence, banks need to again upvote on the customer to acknowledge the modified data.
     * @param username Customer username as string
     * @param password password as a string
     * @param customerData new hash of the new customer data as string
     * @return public returns(int)
     */
    function modifyCustomer(bytes32 username, bytes32 password,  bytes32 customerData) public returns(int){
        //If the password is not set for the customer, then the incoming password string should be equal to "0"
        Customer storage cust = customers[username];
        require(cust.username != BYTES_NULL,"Customer not found");
        if(!(cust.password == BYTES_NULL && password == 0)) return 0;
        else{
            delete verifiedCustomers[username];
            int256 finalListIndex = getIndexBytes(username,finalCustomerList);
            finalCustomerList[uint256(finalListIndex)] = finalCustomerList[finalCustomerList.length - 1];
            finalCustomerList.pop();
            cust.customerData = customerData;
            cust.bank = msg.sender;
            cust.rating = 0;
            cust.upvote = 0;
            return 1;
        }
    }
    /**
     * Upvote customer by bank
     * @param _username customer name
     * @return public returns(uint)
     */
    function upvoteCustomer(bytes32 _username) public returns(uint){
       Customer storage cust = customers[_username];
       require(cust.username != BYTES_NULL,"Customer not found");
       if(getIndexBytes(_username,customerList) != -1)
        return 0;
       else{
            mapping(address => uint) storage checkIfVoted = customerUpvotes[_username];
            require(checkIfVoted[msg.sender] == 0, "Bank already voted for customer");
            cust.upvote += 1;
            customerUpvotes[_username][msg.sender] = 1;
            if(getTotalNumberOfBanks() == 0) return 0;
            cust.rating = cust.upvote/getTotalNumberOfBanks();
            uint numerator = 100;
            uint afterCalc = numerator * 5/1000;
            if(cust.rating > afterCalc){
                verifiedCustomers[_username] = cust;
                finalCustomerList.push(_username);
            }
            return 1;
       }
    }
   /**
     * fetches the KYC requests for a specific bank
     * @param _bank Unique bank address as address is provided to fetch the bank kyc requests
     * @return public view returns(bytes32[] memory, bytes32[] memory, address[] memory, bool[] memory)
     */
    function getKycRequestsFor(address _bank) public view returns(bytes32[] memory, bytes32[] memory, address[] memory, bool[] memory){
        uint requestsLength = customerDataList.length;
        bytes32[] memory usernames = new bytes32[](requestsLength);
        bytes32[] memory customerDatas = new bytes32[](requestsLength);
        address[] memory bankAddresses = new address[](requestsLength);
        bool[] memory allows = new bool[](requestsLength);
        
        for (uint256 i = 0; i < requestsLength; i++){
            if (kycRequests[customerDataList[i]].bankAddress == _bank) {
                KYCRequest storage req = kycRequests[customerDataList[i]];
                usernames[i] = req.username;
                customerDatas[i] = req.customerData;
                bankAddresses[i] = req.bankAddress;
                allows[i] = req.isAllowed;
            }
        }
        return (usernames, customerDatas,bankAddresses,allows);
    }
    /**
     * add and update votes for the banks
     * @param _upvoteFor address of bank
     * @return public returns(uint)
     */
    function upvoteBank(address _upvoteFor) public returns(uint){
       Bank storage tobeUpvoted = banks[_upvoteFor];
       require(tobeUpvoted.ethAddress == address(0),"Bank not found");
       //If the sender already has voted for the bank then reject the request
       require(bankUpvotes[_upvoteFor][msg.sender] == 0, "Bank already voted for customer");
       bankUpvotes[_upvoteFor][msg.sender] = 1;
       tobeUpvoted.rating++;
       return 0;
    }
    /**
     * fetch customer rating from the smart contract.
     * @param ratingOf customer name 
     * @return public view returns(uint)
     */
  
    function getCustomerRating(bytes32 ratingOf) public view returns(uint){
        return customers[ratingOf].rating;
    }
    /**
     * fetch bank rating from the smart contract.
     * @param ratingOf address of the bank for whom we need to fetch the rating
     * @return public view returns(uint)
     */
    function getBankRating(address ratingOf) public view returns(uint){
        return banks[ratingOf].rating;
    }
   /**
     * fetch the bank details which made the last changes to the customer data
     * @param accessHistoryFor customer name
     * @return public view returns(address)
     */
    function getAccessHistory(bytes32 accessHistoryFor) public view returns(address){
        return customers[accessHistoryFor].bank;
        
    }
    /**
     * set the passwords for the customer
     * @param username username of customer
     * @param password password to be set
     * @return public returns(bool)
     */
    function setPassword(bytes32 username, bytes32 password) public returns(bool){
        Customer storage cust = customers[username];
        if(cust.username == BYTES_NULL) return false;
        cust.password = password;
        return true;
    }
    /**
     * Get bank details based on bank address
     * @param getDetailsFor address of the bank
     * @return public returns(bytes32 name, address bankAddress, uint rating, uint kyc_count,bytes32 regNumber)
     */
    function getBankDetails(address getDetailsFor) public view returns(bytes32, address,uint, uint,bytes32){
        Bank storage bnk = banks[getDetailsFor];
        return (bnk.name, bnk.ethAddress,bnk.rating, bnk.kyc_count,bnk.regNumber);
    }
}



