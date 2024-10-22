// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenShock} from "../src/Token.sol";

contract TokenShockTest is Test {
    TokenShock token;
    address owner = address(0xABCD);
    address user = address(0x1234);
    address marketingAdd = address(0x1111);
    address poolRewardAdd = address(0x2222);
    address pair = address(0x3333);

    function setUp() public {
        token = new TokenShock(marketingAdd, poolRewardAdd);
        token.setPair(pair);

        // Repartir fondos iniciales
        vm.deal(owner, 1 ether);
        vm.deal(user, 1 ether);
        
        // Transferir algunos tokens al usuario
        vm.prank(owner);
        token.transfer(user, 1000 * 10**18);
    }

    function testInitialSetup() public {
        vm.skip(true);
        assertEq(token.name(), "SHOCK");
        assertEq(token.symbol(), "SHOCK");
        assertEq(token.totalSupply(), 21_000_000 * 10**18);
        assertEq(token.balanceOf(owner), 21_000_000 * 10**18 - 1000 * 10**18);
        assertEq(token.balanceOf(user), 1000 * 10**18);
    }

    function testTransfer() public {
        vm.skip(true);
        uint256 transferAmount = 100 * 10**18;

        vm.prank(user);
        token.transfer(marketingAdd, transferAmount);

        assertEq(token.balanceOf(user), 900 * 10**18);
        assertEq(token.balanceOf(marketingAdd), transferAmount);
    }

    function testApproveAndTransferFrom() public {
        vm.skip(true);
        uint256 approveAmount = 500 * 10**18;
        uint256 transferAmount = 300 * 10**18;

        vm.prank(user);
        token.approve(owner, approveAmount);

        vm.prank(owner);
        token.transferFrom(user, poolRewardAdd, transferAmount);

        assertEq(token.balanceOf(user), 700 * 10**18);
        assertEq(token.balanceOf(poolRewardAdd), transferAmount);
        assertEq(token.allowance(user, owner), approveAmount - transferAmount);
    }

    function testTransferWithFees() public {
    uint256 amount = 1000 * 10 ** token.decimals();
    uint256 fee = (amount * 10) / 100; // 10% fee
    uint256 burnAmount = (fee * 30) / 100; // 30% of fee
    uint256 marketingAmount = (fee * 30) / 100; // 30% of fee
    uint256 rewardAmount = (fee * 40) / 100; // 40% of fee
    uint256 netAmount = amount - fee;

    vm.prank(owner);
    token.transfer(user, amount);

    assertEq(token.balanceOf(owner), 21_000_000 * 10 ** token.decimals() - amount);
    assertEq(token.balanceOf(user), netAmount);
    assertEq(token.balanceOf(marketingAdd), marketingAmount);
    assertEq(token.balanceOf(poolRewardAdd), rewardAmount);
    assertEq(token.totalSupply(), 21_000_000 * 10 ** token.decimals() - burnAmount);
}

function testSetAddresses() public {
        vm.skip(true);
        address newMarketingAdd = address(0x4444);
        address newPoolRewardAdd = address(0x5555);

        vm.prank(owner);
        token.setMarketingAdd(newMarketingAdd);

        vm.prank(owner);
        token.setPoolRewardAdd(newPoolRewardAdd);

        assertEq(token.marketingAddress(), newMarketingAdd);
        assertEq(token.poolRewardAddress(), newPoolRewardAdd);
    }
}