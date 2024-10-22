// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vesting} from "../src/Vesting.sol";

contract VestingScript is Script {
    Vesting public vesting;

    address shockToken = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; //complete with correct address;
    address usdcToken = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        vesting = new Vesting(shockToken, usdcToken);

        vm.stopBroadcast();
    }
}
