//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Land is ReentrancyGuard {
    address contractOwner;

    constructor() {
        contractOwner = msg.sender;
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
    }

    // If the current owner approves then only the buyer can send money

    struct LandRequest {
        uint reqId;
        address payable sellerId;
        address payable buyerId;
        uint landId;
        reqStatus requestStatus;
        bool isPaymentDone;
        uint requestTimestamp;
    }

    enum reqStatus {
        requested,
        accepted,
        rejected,
        paymentdone,
        commpleted
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

    // modifer
    function isContractOwner(address _addr) public view returns (bool) {
        if (_addr == contractOwner) return true;
        else return false;
    }

    //remove
    function changeContractOwner(address _addr) public {
        require(msg.sender == contractOwner, "you are not contractOwner");
        contractOwner = _addr;
    }

    //-----------------------------------------------User-----------------------------------------------

    function isUserRegistered(address _addr) public view returns (bool) {
        if (RegisteredUserMapping[_addr]) {
            return true;
        } else {
            return false;
        }
    }

    event NewUserRegistered(
        address,    
        string _name,
        uint _age,
        string _city,
        string _aadharNumber,
        string _panNumber,
        string _document,
        string _email
    );

    function registerUser(
        string memory _name,
        uint _age,
        string memory _city,
        string memory _aadharNumber,
        string memory _panNumber,
        string memory _document,
        string memory _email
    ) public {
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
            false
        );

        emit NewUserRegistered(msg.sender, _name, _age, _city, _aadharNumber, _panNumber, _document, _email);
    }

    error NotGovernmentOfficial(address msgSender);
    // modifier of government official
    address govOfficialWalletAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    modifier isGovernmentOfficial {
        if(msg.sender != govOfficialWalletAddress) {
            revert NotGovernmentOfficial(msg.sender);
        }
        _;
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
        uint _area,
        string _address,
        uint landPrice,
        string _allLatiLongi,
        uint _propertyPID,
        string _surveyNum,
        string _document
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
            _area,
            _address,
            landPrice,
            _allLatiLongi,
            _propertyPID,
            _surveyNum,
            _document
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

   event LandIsRequestedToBuy(uint landID);

    function requestforBuy(uint _landId) public {
        require(isUserVerified(msg.sender) && isLandVerified(_landId));
        requestCount++;
        LandRequestMapping[requestCount] = LandRequest(
            requestCount,
            lands[_landId].ownerAddress,
            payable(msg.sender),
            _landId,
            reqStatus.requested,
            false,
            block.timestamp
        );
        MyReceivedLandRequest[lands[_landId].ownerAddress].push(requestCount);
        MySentLandRequest[msg.sender].push(requestCount);

        emit LandIsRequestedToBuy(_landId);
    }

    function myReceivedLandRequests() public view returns (uint[] memory) {
        return MyReceivedLandRequest[msg.sender];
    }

    function mySentLandRequests() public view returns (uint[] memory) {
        return MySentLandRequest[msg.sender];
    }

    function acceptRequest(uint _requestId) public {
        require(LandRequestMapping[_requestId].sellerId == msg.sender);
        LandRequestMapping[_requestId].requestStatus = reqStatus.accepted;
    }

    function rejectRequest(uint _requestId) public {
        require(LandRequestMapping[_requestId].sellerId == msg.sender);
        LandRequestMapping[_requestId].requestStatus = reqStatus.rejected;
    }

    function requesteStatus(uint id) public view returns (bool) {
        return LandRequestMapping[id].isPaymentDone;
    }

    function landPrices(uint id) public view returns (uint) {
        return lands[id].landPrice;
    }

    error PaymentAlreadyCompleted();

    function makePayment(uint _requestId) public payable {
        require(
            LandRequestMapping[_requestId].buyerId == msg.sender &&
                LandRequestMapping[_requestId].requestStatus ==
                reqStatus.accepted
        );
        if (LandRequestMapping[_requestId].isPaymentDone != false) revert PaymentAlreadyCompleted();

        LandRequestMapping[_requestId].requestStatus = reqStatus.paymentdone;
        require(
            msg.value >= lands[LandRequestMapping[_requestId].landId].landPrice, 
            "Transacted amount is lesser than current Land price"
        );

        lands[LandRequestMapping[_requestId].landId].ownerAddress.transfer(msg.value);
        LandRequestMapping[_requestId].isPaymentDone = true;
        paymentDoneList[1].push(_requestId);

        transferOwnership(_requestId);
    }

    function returnPaymentDoneList() public view returns (uint[] memory) {
        return paymentDoneList[1];
    }

    function transferOwnership(uint _requestId)
        internal
        returns (bool) {
        if (LandRequestMapping[_requestId].isPaymentDone == false) return false;
        // documentId++;
        LandRequestMapping[_requestId].requestStatus = reqStatus.commpleted;
        MyLands[LandRequestMapping[_requestId].buyerId].push(
            LandRequestMapping[_requestId].landId
        );

        uint len = MyLands[LandRequestMapping[_requestId].sellerId].length;
        for (uint i = 0; i < len; i++) {
            if (
                MyLands[LandRequestMapping[_requestId].sellerId][i] == LandRequestMapping[_requestId].landId
            ) {
                MyLands[LandRequestMapping[_requestId].sellerId][i] = MyLands[LandRequestMapping[_requestId].sellerId][len - 1];
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

    function makePaymentTestFun(address payable _reveiver) public payable {
        _reveiver.transfer(msg.value);
    }
}
