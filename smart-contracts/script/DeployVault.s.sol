// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {AavePool} from "../src/AaveMock.sol";
import {VaultFactory} from "../src/VaultFactory.sol";

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

        // Deploy the AavePool contract
        AavePool aavePool = new AavePool();
        // Deploy the VaultFactory contract
        VaultFactory vaultFactory = new VaultFactory();

        Vault vault = new Vault(
            msg.sender, // vault owner
            address(vaultFactory), // factory
            address(aavePool), // aavePool mock
            config.hyperlaneMailboxAddress, // mailbox
            config.usdcAddress, // usdc
            config.tokenMessenger, // tokenMessenger
            config.cctpChainId, // cctpChainId
            config.cctpValue // cctpChainValue
        );

        vaultFactory.addVault(address(vault));

        aavePool.setUserData(1000, 1000, 1000, 1000, 1000, 1000);

        vm.stopBroadcast();
        return (vault, helperconfig);
    }
}
