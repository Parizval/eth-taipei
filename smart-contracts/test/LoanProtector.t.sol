// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {LoanProtector} from "../src/LoanProtector.sol";



contract LoanProtectorTest is Test {
    LoanProtector public loanProtector;

    function setUp() public {
        loanProtector = new LoanProtector();
    }

}
