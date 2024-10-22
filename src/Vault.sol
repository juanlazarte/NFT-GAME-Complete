// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract ShockVault is ERC1155Holder {
    address public nftContract;
    mapping(address => mapping(uint256 => uint256)) public balances;

    event NFTDeposited(address indexed user, uint256 tokenId, uint256 amount);
    event NFTWithdrawn(address indexed user, uint256 tokenId, uint256 amount);

    constructor(address _nftContract) {
        nftContract = _nftContract;
    }

    function deposit(uint256 tokenId, uint256 amount) external {
        require(IERC1155(nftContract).isApprovedForAll(msg.sender, address(this)), "Contract is not approved for all");

        IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        balances[msg.sender][tokenId] += amount;

        emit NFTDeposited(msg.sender, tokenId, amount);
    }

    function withdraw(uint256 tokenId, uint256 amount) external {
        require(balances[msg.sender][tokenId] >= amount, "Insufficient balance");

        IERC1155(nftContract).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");

        balances[msg.sender][tokenId] -= amount;

        emit NFTWithdrawn(msg.sender, tokenId, amount);
    }
}