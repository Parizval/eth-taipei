// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

contract VaultScript is Script {
    Vault public vault;

    function setUp() public {}

    function run() public {
        // Set up the environment
        vm.startBroadcast();

        vault = new Vault(
            address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), 8, 9
        );

        vm.stopBroadcast();
    }
}
