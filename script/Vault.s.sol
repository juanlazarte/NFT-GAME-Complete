// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ShockVault} from "../src/Vault.sol";

contract VaultScript is Script {
    ShockVault public vault;

    address nftContract = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; //complete with correct address;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        vault = new ShockVault(nftContract);

        vm.stopBroadcast();
    }
}
