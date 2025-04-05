// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AavePool} from "../src/AaveMock.sol";

contract VaultScript is Script {
    AavePool public aavePool;

    function setUp() public {}

    function run() public {
        // Set up the environment
        vm.startBroadcast();

        aavePool = new AavePool();

        vm.stopBroadcast();
    }
}
