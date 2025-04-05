// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AaveFetch} from "../src/AaveFetch.sol";

contract CounterTest is Test {
    AaveFetch public counter;

    function setUp() public {
        counter = new AaveFetch(0x794a61358D6845594F94dc1DB02A252b5b4814aD);
    }

    // function testVaulue() public {
    //     counter.getAaveData(0xE451141fCE63EB38e85F08a991fC5878Ee6335b2);

    //     console.log(counter.ltv());
    //     console.log(counter.totalCollateralBase());
    //     console.log(counter.totalDebtBase());
    //     console.log(counter.healthFactor());
    //     assertEq(counter.ltv(), 7000);
    // }
}
