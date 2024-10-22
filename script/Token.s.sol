// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TokenShock} from "../src/Token.sol";

contract TokenScript is Script {
    TokenShock public token;

    address marketingAdd = 0xA16c5DA8b55297099D0b2Ad36e8D92030fB4A681;
    address poolRewardAdd = 0xA16c5DA8b55297099D0b2Ad36e8D92030fB4A681;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new TokenShock(marketingAdd, poolRewardAdd);

        vm.stopBroadcast();
    }
}
