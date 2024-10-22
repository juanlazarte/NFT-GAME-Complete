// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

error NotTranferComplete();
error NotBalance();

contract shockNFT is ERC1155, ERC1155Supply, VRFConsumerBaseV2Plus {
    string public name; //Collection name
    string public symbol; //Collection symbol

    //PRICE IN USDC
    uint256 public immutable PROTO_PRICE = 35000000; //35$
    uint256 public immutable CYBER_PRICE = 50000000; //50$
    uint256 public immutable BIONIC_PRICE = 75000000; //75$
    uint256 public immutable MYLITARY_PRICE = 97000000; //97$

    IERC20 public USDC;

    //VRF
    //Variable para  almacenar ultimo numero
    uint256 public lastRandomNumber;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
        uint256 num;
    }

    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    // Fuji coordinator
    // https://docs.chain.link/vrf/v2-5/supported-networks#avalanche-fuji-testnet
    IVRFCoordinatorV2Plus COORDINATOR;
    address vrfCoordinator = 0x5C210eF41CD1a72de73bF76eC39637bB0d3d7BEE;
    bytes32 keyHash =
        0xc799bd1e3bd4d1a41cd4968997a4e03dfd2a3c7c04b695881138580163f42887;
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    // past requests Ids.
    uint256[] public requestIds;
    uint256 public lastRequestId;
    /*     uint256[] public lastRandomWords; */

    // Your subscription ID.
    uint256 public s_subscriptionId;

    constructor(
        string memory _name,
        string memory _symbol,
        address _usdcToken,
        uint256 subscriptionId
    )
        ERC1155(
            "https://ipfs.io/ipfs/QmSCXFTa5bvyiBB8gb8uYu3YNhyFNvhycpJ7vNdUxjqLXP/{id}.json" //Example
        )
        VRFConsumerBaseV2Plus(vrfCoordinator)
    {
        name = _name;
        symbol = _symbol;
        USDC = IERC20(_usdcToken);

        COORDINATOR = IVRFCoordinatorV2Plus(vrfCoordinator);
        s_subscriptionId = subscriptionId;
    }

    //URI
    function uri(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(exists(_tokenId), "URI: id doesn't exist");
        return
            string(
                abi.encodePacked(
                    super.uri(_tokenId),
                    Strings.toString(_tokenId),
                    ".json"
                )
            );
    }

    //BOXES
    //PROTO BOX 35$ (90% 5 Proto Cards OR 10% 4 Proto Cards + 1 Cyber Card)
    function protoBox() public returns (uint256 requestId) {
        if (USDC.balanceOf(msg.sender) < PROTO_PRICE) {
            revert NotBalance();
        }
        if (!USDC.transferFrom(msg.sender, address(this), PROTO_PRICE)) {
            revert NotTranferComplete();
        }

        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            num: 0
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);

        boxType(1);
        return requestId;
    }

    //CYBER BOX 50$ (80% 3 Cyber Cards + 2 Proto Cards OR 20% 4 Cyber Cards + 1 Proto Card )
    function cyberBox() public returns (uint256 requestId) {
        if (USDC.balanceOf(msg.sender) < CYBER_PRICE) {
            revert NotBalance();
        }
        if (!USDC.transferFrom(msg.sender, address(this), CYBER_PRICE)) {
            revert NotTranferComplete();
        }

        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            num: 0
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        boxType(2);

        return requestId;
    }

    //BIONIC BOX 75$ (80% 3 Bionic Cards + 2 Cyber Cards OR 20% 4 Bionic Cards + 1 Cyber Card  )
    function bionicBox() public returns (uint256 requestId) {
        if (USDC.balanceOf(msg.sender) < BIONIC_PRICE) {
            revert NotBalance();
        }
        if (!USDC.transferFrom(msg.sender, address(this), BIONIC_PRICE)) {
            revert NotTranferComplete();
        }

        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            num: 0
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);

        boxType(3);

        return requestId;
    }

    //MILITARY BOX 97$ (3 Proto Cards 3 Cyber Cards 2 Bionic Cards) FIXED
    function militaryBox() public returns (uint256 requestId) {
        if (USDC.balanceOf(msg.sender) < MYLITARY_PRICE) {
            revert NotBalance();
        }
        if (!USDC.transferFrom(msg.sender, address(this), MYLITARY_PRICE)) {
            revert NotTranferComplete();
        }

        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            num: 0
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);

        boxType(4);

        return requestId;
    }

    //VRF FUNCTIONS
    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId /* requestId */,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        uint randomNum = (_randomWords[0] % 100) + 1; //numero del 1 al 100
        s_requests[_requestId].num = randomNum;
        lastRandomNumber = randomNum;

        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {}

    function boxType(uint256 _type) internal {
        if (_type == 1) {
            mintProtoBox();
        } else if (_type == 2) {
            mintCyberBox();
        } else if (_type == 3) {
            mintBionicBox();
        } else if (_type == 4) {
            mintMiliratyBox();
        }
    }

    //MINTS
    function mintProtoBox() internal {
        if (lastRandomNumber >= 90) {
            protoOpcionOne();
        } else {
            protoOpciontwo();
        }
    }

    function mintCyberBox() internal {
        if (lastRandomNumber >= 80) {
            cyberOpcionOne();
        } else {
            cyberOpciontwo();
        }
    }

    function mintBionicBox() internal {
        if (lastRandomNumber >= 80) {
            bionicOpcionOne();
        } else {
            bionicOpciontwo();
        }
    }

    function mintMiliratyBox() internal {
        militaryOpcionOne();
    }

    //PROTO OPTIONS
    function protoOpcionOne() internal {
        uint protoRandom = generateRandomProto();
        uint protoRandom2 = generateRandomProto2();
        _mint(msg.sender, protoRandom, 3, ""); //5 protoCards 90%
        _mint(msg.sender, protoRandom2, 2, ""); //5 ProtoCards total
    }

    function protoOpciontwo() internal {
        uint protoRandom = generateRandomProto();
        uint protoRandom2 = generateRandomProto2();
        uint cyberRandom = generateRandomCyber();
        _mint(msg.sender, protoRandom, 2, ""); //4 protoCards
        _mint(msg.sender, protoRandom2, 2, "");
        _mint(msg.sender, cyberRandom, 1, ""); //1 CyberCards 10%
    }

    //CYBER OPTIONS
    function cyberOpcionOne() internal {
        uint protoRandom = generateRandomProto();
        uint cyberRandom = generateRandomCyber();
        uint cyberRandon2 = generateRandomCyber2();
        _mint(msg.sender, cyberRandom, 1, ""); //3 cyberCards
        _mint(msg.sender, cyberRandon2, 2, "");
        _mint(msg.sender, protoRandom, 2, ""); //2 protoCards 80%
    }

    function cyberOpciontwo() internal {
        uint protoRandom = generateRandomProto();
        uint cyberRandom = generateRandomCyber();
        uint cyberRandon2 = generateRandomCyber2();
        _mint(msg.sender, cyberRandom, 2, ""); //4 cyberCards
        _mint(msg.sender, cyberRandon2, 2, "");
        _mint(msg.sender, protoRandom, 1, ""); //1 protoCards 20%
    }

    //BIONIC OPTIONS
    function bionicOpcionOne() internal {
        uint bionicRandom = generateRandomBionic();
        uint bionicRandom2 = generateRandomBionic2();
        uint cyberRandom = generateRandomCyber();
        _mint(msg.sender, bionicRandom, 2, ""); //3 bionicCard
        _mint(msg.sender, bionicRandom2, 1, "");
        _mint(msg.sender, cyberRandom, 2, ""); //2 cyberCards 80%
    }

    function bionicOpciontwo() internal {
        uint bionicRandom = generateRandomBionic();
        uint bionicRandom2 = generateRandomBionic2();
        uint cyberRandom = generateRandomCyber();
        _mint(msg.sender, bionicRandom, 2, ""); //4 bionicCards
        _mint(msg.sender, bionicRandom2, 2, "");
        _mint(msg.sender, cyberRandom, 1, ""); //1 cyberCards 20%
    }

    //MILITARY OPTIONS
    function militaryOpcionOne() internal {
        uint protoRandom = generateRandomProto();
        uint protoRandom2 = generateRandomProto2();
        uint cyberRandom = generateRandomCyber();
        uint cyberRandon2 = generateRandomCyber2();
        uint bionicRandom = generateRandomBionic();
        uint bionicRandom2 = generateRandomBionic2();
        _mint(msg.sender, protoRandom, 2, ""); //3 protoCard
        _mint(msg.sender, protoRandom2, 1, "");
        _mint(msg.sender, cyberRandom, 2, ""); //3 CyberCard
        _mint(msg.sender, cyberRandon2, 1, "");
        _mint(msg.sender, bionicRandom, 1, ""); //2 bionicCard 100%
        _mint(msg.sender, bionicRandom2, 1, ""); //
    }

    function generateRandomProto() internal view returns (uint256) {
        uint256 randomNumberProto = (uint256(
            keccak256(abi.encodePacked(block.timestamp, lastRandomNumber, "1"))
        ) % 6) + 1; //id 1-6
        return randomNumberProto;
    }

    function generateRandomCyber() internal view returns (uint256) {
        uint256 randomNumberCyber = (uint256(
            keccak256(abi.encodePacked(block.timestamp, lastRandomNumber, "2"))
        ) % 6) + 7; //id 7-12
        return randomNumberCyber;
    }

    function generateRandomBionic() internal view returns (uint256) {
        uint256 randomNumberBionic = (uint256(
            keccak256(abi.encodePacked(block.timestamp, lastRandomNumber, "3"))
        ) % 6) + 13; //id 13-18
        return randomNumberBionic;
    }

    function generateRandomProto2() internal view returns (uint256) {
        uint256 randomNumberProto = (uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, "1"))
        ) % 6) + 1; //id 1-6
        return randomNumberProto;
    }

    function generateRandomCyber2() internal view returns (uint256) {
        uint256 randomNumberCyber = (uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, "2"))
        ) % 6) + 7; //id 7-12
        return randomNumberCyber;
    }

    function generateRandomBionic2() internal view returns (uint256) {
        uint256 randomNumberBionic = (uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, "3"))
        ) % 6) + 13; //id 13-18
        return randomNumberBionic;
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}
