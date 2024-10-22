// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error TimeOut();
error NotMember();
error MaxClaim();
error PriceMustBeAboveZero();
error MaxTokensToBuy();
error NotTransferComplete();
error NoBalance();
error NotApproveComplete();

contract Vesting is Ownable {
    struct VestingInfo {
        uint256 amount;
        uint256 lastClaimTime;
        uint256 claimCount;
        bool isMember;
    }

    uint256 public constant interval = 30 seconds;
    uint256 public constant teamMaxClaims = 5;
    uint256 public constant publicMaxClaims = 16;
    uint256 public constant teamReleasePercentage = 20;
    uint256 public constant publicReleasePercentage = 6250; // 6.25% expressed as a fraction

    uint256 public tokenPriceInUsdt = 1; // Precio del token en USDT
    uint256 public totalVestingTokens = 100; // Cantidad total de tokens disponibles para la preventa

    IERC20 public SHOCK;
    IERC20 public USDC;

    mapping(address => VestingInfo) public teamVestings;
    mapping(address => VestingInfo) public publicVestings;
    mapping(address => uint256) public balances;

    event TeamMemberAdded(address indexed member);
    event PublicMemberAdded(address indexed member);
    event TeamMemberRevoked(address indexed member);
    event PublicMemberRevoked(address indexed member);
    event TokensPurchased(address indexed buyer, uint256 amount);
    event TokensClaimed(address indexed member, uint256 amount);

    modifier timeOut {
        if(block.timestamp < teamVestings[msg.sender].lastClaimTime + interval) {
            revert TimeOut();
        }
        _;
    }

    modifier onlyTeamMember {
        if (teamVestings[msg.sender].isMember == false) {
            revert NotMember();
        }
        _;
    }

    modifier onlyPublicMember {
        if (publicVestings[msg.sender].isMember == false) {
            revert NotMember();
        }
        _;
    }

    constructor(address _shockToken, address _usdcToken) Ownable(msg.sender) {
        SHOCK = IERC20(_shockToken);
        USDC = IERC20(_usdcToken);
    }

    function setTokenPrice(uint256 _priceInUsdt) external onlyOwner {
        tokenPriceInUsdt = _priceInUsdt;
    }

    function addTeamMember(address _member) external onlyOwner {
        teamVestings[_member].isMember = true;
        emit TeamMemberAdded(_member);
    }

    function addPublicMember(address _member) external onlyOwner {
        publicVestings[_member].isMember = true;
        emit PublicMemberAdded(_member);
    }

    function revokeTeamMember(address _member) external onlyOwner {
        teamVestings[_member].isMember = false;
        emit TeamMemberRevoked(_member);
    }

    function revokePublicMember(address _member) external onlyOwner {
        publicVestings[_member].isMember = false;
        emit PublicMemberRevoked(_member);
    }

    function buyTeamTokens(uint256 tokensToBuy) external timeOut onlyTeamMember {
        if (teamVestings[msg.sender].claimCount >= teamMaxClaims) {
            revert MaxClaim();
        }
        if (tokensToBuy == 0) {
            revert PriceMustBeAboveZero();
        }

        uint256 currentTime = block.timestamp;
        VestingInfo storage teamvesting = teamVestings[msg.sender];

        uint256 maxTokens = (totalVestingTokens * teamReleasePercentage) / 100;
        if (tokensToBuy > maxTokens) {
            revert MaxTokensToBuy();
        }

        uint256 amountInUsdc = (tokensToBuy * tokenPriceInUsdt);

        if (USDC.balanceOf(msg.sender) < amountInUsdc) {
            revert NoBalance();
        }

        if (!USDC.approve(address(this), amountInUsdc)) {
            revert NotApproveComplete();
        }
        if (!USDC.transferFrom(msg.sender, address(this), amountInUsdc)) {
            revert NotTransferComplete();
        }

        teamvesting.amount += tokensToBuy;
        teamvesting.lastClaimTime = currentTime;
        teamvesting.claimCount++;

        balances[msg.sender] += tokensToBuy;

        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function buyPublicTokens(uint256 tokensToBuy) external timeOut onlyPublicMember {
        if (publicVestings[msg.sender].claimCount >= publicMaxClaims) {
            revert MaxClaim();
        }
        if (tokensToBuy == 0) {
            revert PriceMustBeAboveZero();
        }

        uint256 currentTime = block.timestamp;
        VestingInfo storage publicvesting = publicVestings[msg.sender];

        uint256 maxTokens = (totalVestingTokens * publicReleasePercentage) / 10000;
        if (tokensToBuy > maxTokens) {
            revert MaxTokensToBuy();
        }

        uint256 amountInUsdc = (tokensToBuy * tokenPriceInUsdt);

        if (USDC.balanceOf(msg.sender) < amountInUsdc) {
            revert NoBalance();
        }

        if (!USDC.approve(address(this), amountInUsdc)) {
            revert NotApproveComplete();
        }
        if (!USDC.transferFrom(msg.sender, address(this), amountInUsdc)) {
            revert NotTransferComplete();
        }        
        
        publicvesting.amount += tokensToBuy;
        publicvesting.lastClaimTime = currentTime;
        publicvesting.claimCount++;

        balances[msg.sender] += tokensToBuy;

        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function withdrawTokens() external {
        uint256 tokensToClaim = balances[msg.sender];
        if(tokensToClaim <= 0) {
            revert NoBalance();
        }
        balances[msg.sender] = 0;
        SHOCK.transfer(msg.sender, tokensToClaim);
    }

    function withdrawUsdc() external onlyOwner {
        uint256 usdcToClaim = USDC.balanceOf(address(this));
        if(usdcToClaim <= 0) {
            revert NoBalance();
        }
        USDC.transfer(msg.sender, usdcToClaim);
    }

    function withdrawExcessTokens() external onlyOwner {
        uint256 totalTokens = SHOCK.balanceOf(address(this));
        if (totalTokens <= 0) {
            revert NoBalance();
        }
        SHOCK.transfer(msg.sender, totalTokens);
    }

    function getTeamVesting(address wallet) external view returns (uint256, uint256, uint256) {
        VestingInfo storage vesting = teamVestings[wallet];
        return (vesting.amount, vesting.lastClaimTime, vesting.claimCount);
    }

    function getPublicVesting(address wallet) external view returns (uint256, uint256, uint256) {
        VestingInfo storage vesting = publicVestings[wallet];
        return (vesting.amount, vesting.lastClaimTime, vesting.claimCount);
    }
}