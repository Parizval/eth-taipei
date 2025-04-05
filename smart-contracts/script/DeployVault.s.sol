// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployVault is Script {
    function setUp() public {}

    function run() public {
        // Set up the environment
        deployContract();
    }

    function deployContract() public returns (Vault, HelperConfig) {
        HelperConfig helperconfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperconfig.getConfig();

        vm.startBroadcast();
        Vault vault = new Vault(
            config.owner, // vault owner
            config.factoryAddress, // _factory
            config.aavePoolAddress, // aavePool
            config.hyperlaneMailboxAddress, // mailbox
            config.usdcAddress, // usdc
            config.tokenMessenger, // tokenMessenger
            config.wormholeRelayer, // wormholeRelayer
            config.tokenBridge, // tokenBridge
            config.wormhole, // wormholeCore
            config.cctpChainId, // cctpChainId
            config.cctpValue // cctpChainValue
        );

        vm.stopBroadcast();
        return (vault, helperconfig);
    }
}
