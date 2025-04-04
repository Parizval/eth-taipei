// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract deployVault is Script {

    function setUp() public {}

    function run() public {
        // Set up the environment
        
    }

    function deployContract() public returns (Vault, HelperConfig) {
        HelperConfig helperconfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperconfig.getConfig();

        vm.startBroadcast();
        Vault vault = new Vault(
            config.owner, // _vaultToken
            config.aavePoolAddress, // _rewardToken
            config.hyperlaneMailboxAddress, // _rewardPool
            config.usdcAddress, // _rewardPoolV2
            config.tokenMessenger, // _rewardPoolV3
            config.wormholeRelayer, // _rewardPoolV4
            config.tokenBridge, // _rewardPoolV5
            config.wormhole, // _rewardPoolV6
            config.cctpChainId, // _cctpChainId
            config.cctpValue
        );

        vm.stopBroadcast();
        return (vault, helperconfig);
    }
}
