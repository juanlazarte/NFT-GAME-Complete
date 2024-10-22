// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {shockNFT} from "../src/PublicSale.sol";

contract NftScript is Script {
    shockNFT public nft;

    string name = "SHOCK NFT";
    string symbol = "SHOCK";
    address usdcToken = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; //complete with correct address;
    uint256 suscriptionId = 123456789; //Complete with suscription id from chainlink

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        nft = new shockNFT(name, symbol, usdcToken, suscriptionId);

        vm.stopBroadcast();
    }
}
