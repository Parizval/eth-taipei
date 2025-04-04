// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LoanProtector} from "../src/LoanProtector.sol";

contract LoanProtectorScript is Script {
    LoanProtector public loanProtector;

    function setUp() public {}

    function run() public {
        // Set up the environment
        vm.startBroadcast();

        loanProtector = new LoanProtector(address(0), address(0), address(0));

        vm.stopBroadcast();
    }
}
