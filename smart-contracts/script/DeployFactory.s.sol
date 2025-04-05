// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {FactoryHelperConfig} from "./FactoryHelperConfig.s.sol";

contract DeployFactory is Script {
    VaultFactory public vaultFactory;

    function setUp() public {}

    function run() public {
        // Set up the environment

        // deployFactoryContract();
        vm.startBroadcast();

        vaultFactory = new VaultFactory();

        vm.stopBroadcast();

    }

    // function deployFactoryContract() public returns (VaultFactory, FactoryHelperConfig) {
    //     FactoryHelperConfig helperconfig = new FactoryHelperConfig();
    //     FactoryHelperConfig.NetworkConfig memory config = helperconfig.getConfig();

    //     vm.startBroadcast();
    //     VaultFactory vault = new VaultFactory(
    //         config.aavePoolAddress, // _aavePool
    //         config.hyperlaneMailboxAddress, // _mailbox
    //         config.usdcAddress, // _usdc
    //         config.tokenMessenger, // _tokenMessenger
    //         config.wormholeRelayer, // _wormholeRelayer
    //         config.tokenBridge, // _wormholeTokenBridge
    //         config.wormhole, // _wormholeCore
    //         config.cctpChainId, // _cctpChainId
    //         config.cctpValue // _cctpChainValue
    //     );

    //     vm.stopBroadcast();
    //     return (vault, helperconfig);
    // }
}
