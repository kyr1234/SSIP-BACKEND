//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Land is ReentrancyGuard {
    address GovernmentOfficial;
    uint public governmentFeesRate = 4;
    uint count = 0;

    constructor() {
        GovernmentOfficial = msg.sender;
    }

    enum OwnerApprovalStatus {
        REQUESTED,
        ACCEPTED,
        REJECTED,
        PAYMENT_DONE,
        COMPLETED
    }

    enum GovernmentApprovalStatus {
        PENDING,
        ACCEPTED,
        REJECTED
    }

    struct Landreg {
        uint id;
        //double area
        uint area;
        string landAddress;
        uint landPrice;
        string allLatitudeLongitude;
        //string allLongitude;
        uint propertyPID;
        string physicalSurveyNumber;
        string document;
        //remove
        bool isforSell;
        address payable ownerAddress;
        bool isLandVerified;
    }

    struct User {
        address id;
        string name;
        uint age;
        string city;
        string aadharNumber;
        string panNumber;
        string document;
        string email;
        bool isUserVerified;
        bool isExist;
    }

    // If the current owner approves then only the buyer can send money
    struct LandRequest {
        uint reqId;
        address payable sellerId;
        address payable buyerId;
        uint landId;
        OwnerApprovalStatus requestStatus;
        bool isPaymentDone;
        uint requestTimestamp;
        GovernmentApprovalStatus govApprovalStatus;
    }

    // USER AND LAND MAPPING
    uint public userCount;
    uint public landsCount;
    uint public documentId;
    uint requestCount;

    mapping(address => User) public UserMapping;

    //REMOVE
    mapping(uint => address) AllUsers;

    //REMOVE
    mapping(uint => address[]) allUsersList;

    mapping(address => bool) RegisteredUserMapping;
    mapping(address => uint[]) MyLands;

    mapping(uint => Landreg) public lands;
    mapping(uint => LandRequest) public LandRequestMapping;
    mapping(address => uint[]) MyReceivedLandRequest;
    mapping(address => uint[]) MySentLandRequest;

    //remove
    mapping(uint => uint[]) allLandList;

    mapping(uint => uint[]) paymentDoneList;

    //remove
    function changeContractOwner(address _addr) public {
        require(msg.sender == GovernmentOfficial, "you are not contractOwner");
        GovernmentOfficial = _addr;
    }

    //-----------------------------------------------User-----------------------------------------------

    function isUserRegistered(address _addr) external view returns (bool) {
        if (RegisteredUserMapping[_addr]) {
            return true;
        } else {
            return false;
        }
    }

    event NewUserRegistered(
        address indexed useraddress,
        string _name,
        uint _age,
        string _city,
        string _aadharNumber,
        string indexed _panNumber,
        string indexed _document,
        string _email
    );

    modifier UserNotGovernmentOfficial(address sender) {
        require(
            sender != GovernmentOfficial,
            "Government official cannot register as User"
        );
        _;
    }

    function registerUser(
        string memory _name,
        uint _age,
        string memory _city,
        string memory _aadharNumber,
        string memory _panNumber,
        string memory _document,
        string memory _email
    ) public UserNotGovernmentOfficial(msg.sender) {
        require(!RegisteredUserMapping[msg.sender]);

        RegisteredUserMapping[msg.sender] = true;
        userCount++;
        allUsersList[1].push(msg.sender);
        AllUsers[userCount] = msg.sender;
        UserMapping[msg.sender] = User(
            msg.sender,
            _name,
            _age,
            _city,
            _aadharNumber,
            _panNumber,
            _document,
            _email,
            false,
            true
        );

        emit NewUserRegistered(
            msg.sender,
            _name,
            _age,
            _city,
            _aadharNumber,
            _panNumber,
            _document,
            _email
        );
    }

    error NotGovernmentOfficial(address msgSender);

    modifier isGovernmentOfficial() {
        if (msg.sender != GovernmentOfficial) {
            revert NotGovernmentOfficial(msg.sender);
        }
        _;
    }

    function changeGovernmentFeesRate(uint rate) external isGovernmentOfficial {
        governmentFeesRate = rate;
    }

    event UserVerified(address);

    function verifyUser(address userWalletAddress) public isGovernmentOfficial {
        UserMapping[userWalletAddress].isUserVerified = true;
        emit UserVerified(userWalletAddress);
    }

    function isUserVerified(address id) public view returns (bool) {
        return UserMapping[id].isUserVerified;
    }

    function ReturnAllUserList() public view returns (address[] memory) {
        return allUsersList[1];
    }

    //-----------------------------------------------Land-----------------------------------------------
    event NewLandAdded(
        uint landID,
        uint _area,
        string _address,
        uint landPrice,
        string _allLatiLongi,
        uint indexed _propertyPID,
        string indexed _surveyNum
    );

    function addLand(
        uint _area,
        string memory _address,
        uint landPrice,
        string memory _allLatiLongi,
        uint _propertyPID,
        string memory _surveyNum,
        string memory _document
    ) public {
        require(isUserVerified(msg.sender));
        landsCount++;
        lands[landsCount] = Landreg(
            landsCount,
            _area,
            _address,
            landPrice,
            _allLatiLongi,
            _propertyPID,
            _surveyNum,
            _document,
            false,
            payable(msg.sender),
            false
        );
        MyLands[msg.sender].push(landsCount);

        //  allLandList[1].push(landsCount);
        emit NewLandAdded(
            landsCount,
            _area,
            _address,
            landPrice,
            _allLatiLongi,
            _propertyPID,
            _surveyNum
        );
    }

    function ReturnAllLandList() public view returns (uint[] memory) {
        return allLandList[1];
    }

    // modifier government official
    function verifyLand(uint _id) public isGovernmentOfficial {
        lands[_id].isLandVerified = true;
    }

    function isLandVerified(uint id) public view returns (bool) {
        return lands[id].isLandVerified;
    }

    function myAllLands(address id) public view returns (uint[] memory) {
        return MyLands[id];
    }

    /*     
        function makeItforSell(uint id) public {
        require(lands[id].ownerAddress == msg.sender);
        lands[id].isforSell = true;
    } 
    */

    event LandIsRequestedToBuy(uint requestID, uint landID);

    function requestforBuy(uint _landId)
        public
        UserNotGovernmentOfficial(msg.sender)
        returns (uint)
    {
        require(
            isUserVerified(msg.sender) && isLandVerified(_landId),
            "User and Land both MUST be verified"
        );
        require(
            msg.sender != lands[_landId].ownerAddress,
            "Owner cannot request for buying land"
        );

        requestCount++;
        LandRequestMapping[requestCount] = LandRequest(
            requestCount,
            lands[_landId].ownerAddress,
            payable(msg.sender),
            _landId,
            OwnerApprovalStatus.REQUESTED,
            false,
            block.timestamp,
            GovernmentApprovalStatus.PENDING
        );
        MyReceivedLandRequest[lands[_landId].ownerAddress].push(requestCount);
        MySentLandRequest[msg.sender].push(requestCount);

        emit LandIsRequestedToBuy(requestCount, _landId);
        return requestCount;
    }

    function myReceivedLandRequests() public view returns (uint[] memory) {
        return MyReceivedLandRequest[msg.sender];
    }

    function mySentLandRequests() public view returns (uint[] memory) {
        return MySentLandRequest[msg.sender];
    }

    function acceptRequest(uint _requestId) public {
        require(LandRequestMapping[_requestId].sellerId == msg.sender);
        LandRequestMapping[_requestId].requestStatus = OwnerApprovalStatus
            .ACCEPTED;
    }

    function rejectRequest(uint _requestId) public {
        require(LandRequestMapping[_requestId].sellerId == msg.sender);
        LandRequestMapping[_requestId].requestStatus = OwnerApprovalStatus
            .REJECTED;
    }

    function isUserRequestFulfilled(uint id) public view returns (bool) {
        return LandRequestMapping[id].isPaymentDone;
    }

    function landPrices(uint id) public view returns (uint) {
        return lands[id].landPrice;
    }

    modifier GovernmentApprovalCheck(uint _requestId) {
        require(
            LandRequestMapping[_requestId].requestStatus ==
                OwnerApprovalStatus.ACCEPTED,
            "Owner MUST approve to sell asset"
        );
        require(
            LandRequestMapping[_requestId].govApprovalStatus ==
                GovernmentApprovalStatus.ACCEPTED,
            "Government MUST approve the Transaction"
        );
        _;
    }

    function changeGovernmentStatus(uint _requestID, uint status)
        public
        isGovernmentOfficial
    {
        GovernmentApprovalStatus g = GovernmentApprovalStatus.PENDING;

        if (status == 0) {
            g = GovernmentApprovalStatus.PENDING;
        } else if (status == 1) {
            g = GovernmentApprovalStatus.ACCEPTED;
        } else if (status == 2) {
            g = GovernmentApprovalStatus.REJECTED;
        }

        LandRequestMapping[_requestID].govApprovalStatus = g;
    }

    error PaymentAlreadyCompleted();
    error TransactionFailed();

    function makePayment(uint _requestId)
        public
        payable
        GovernmentApprovalCheck(_requestId)
    {
        require(
            LandRequestMapping[_requestId].buyerId == msg.sender &&
                LandRequestMapping[_requestId].requestStatus ==
                OwnerApprovalStatus.ACCEPTED
        );
        if (LandRequestMapping[_requestId].isPaymentDone != false)
            revert PaymentAlreadyCompleted();

        LandRequestMapping[_requestId].requestStatus = OwnerApprovalStatus
            .PAYMENT_DONE;
        require(
            msg.value >= lands[LandRequestMapping[_requestId].landId].landPrice,
            "Transacted amount is lesser than current Land price"
        );

        uint transferAmount = msg.value;
        uint governmentFeesAmount;
        governmentFeesAmount = (governmentFeesRate * transferAmount) / 100;
        transferAmount -= governmentFeesAmount;

        (bool govTxStatus, ) = payable(GovernmentOfficial).call{
            value: governmentFeesAmount
        }("");
        if (!govTxStatus) revert TransactionFailed();

        address currentAssetOwner = lands[LandRequestMapping[_requestId].landId]
            .ownerAddress;
        (bool Tx, ) = payable(currentAssetOwner).call{value: transferAmount}(
            ""
        );
        if (!Tx) revert TransactionFailed();

        LandRequestMapping[_requestId].isPaymentDone = true;
        paymentDoneList[1].push(_requestId);

        transferOwnership(_requestId);
    }

    function returnPaymentDoneList() public view returns (uint[] memory) {
        return paymentDoneList[1];
    }

    function transferOwnership(uint _requestId) internal returns (bool) {
        if (LandRequestMapping[_requestId].isPaymentDone == false) return false;
        // documentId++;
        LandRequestMapping[_requestId].requestStatus = OwnerApprovalStatus
            .COMPLETED;
        MyLands[LandRequestMapping[_requestId].buyerId].push(
            LandRequestMapping[_requestId].landId
        );

        uint len = MyLands[LandRequestMapping[_requestId].sellerId].length;
        for (uint i = 0; i < len; i++) {
            if (
                MyLands[LandRequestMapping[_requestId].sellerId][i] ==
                LandRequestMapping[_requestId].landId
            ) {
                MyLands[LandRequestMapping[_requestId].sellerId][i] = MyLands[
                    LandRequestMapping[_requestId].sellerId
                ][len - 1];
                MyLands[LandRequestMapping[_requestId].sellerId].pop();
                break;
            }
        }

        // lands[LandRequestMapping[_requestId].landId].document = documentUrl;
        lands[LandRequestMapping[_requestId].landId].isforSell = false;
        lands[LandRequestMapping[_requestId].landId]
            .ownerAddress = LandRequestMapping[_requestId].buyerId;

        return true;
    }

    function getUserByAddress(address userAddress)
        external
        view
        returns (
            address,
            string memory,
            uint,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            bool,
            bool
        )
    {
        User memory u = UserMapping[userAddress];
        return (
            u.id,
            u.name,
            u.age,
            u.city,
            u.aadharNumber,
            u.panNumber,
            u.document,
            u.email,
            u.isUserVerified,
            u.isExist
        );
    }

    function getgovfee() public view returns (uint) {
        return governmentFeesRate;
    }

    function getcount() public view returns (uint) {
        return count;
    }
}
