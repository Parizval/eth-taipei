// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {AavePool} from "../src/AaveMock.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MultiChainDeployVault is Script {
    function setUp() public {}

    function run() public {
        // Set up the environment
        deployContract();
    }

    function deployContract() public returns (Vault, HelperConfig) {
        HelperConfig helperconfig = new HelperConfig();

        uint256 baseFork = vm.createFork(vm.rpcUrl("baseSepolia"));

        uint256 fujiFork = vm.createFork(vm.rpcUrl("fuji"));

        vm.selectFork(baseFork);

        HelperConfig.NetworkConfig memory Baseconfig = helperconfig.getConfig();

        vm.startBroadcast();
        // Deploy the AavePool contract
        AavePool aavePoolBase = new AavePool();

        // console.log("Base AavePool deployed at:", address(aavePoolBase));

        // Deploy the VaultFactory contract
        VaultFactory vaultFactoryBase = new VaultFactory();

        // console.log("Base Vault Factory deployed at:", address(vaultFactoryBase));

        Vault vaultBase = new Vault(
            msg.sender, // vault owner
            address(vaultFactoryBase), // factory
            address(aavePoolBase), // aavePool mock
            Baseconfig.hyperlaneMailboxAddress, // mailbox
            Baseconfig.usdcAddress, // usdc
            Baseconfig.tokenMessenger, // tokenMessenger
            Baseconfig.messageTrasmitter, // messageTrasmitter
            Baseconfig.cctpChainId, // cctpChainId
            Baseconfig.cctpValue // cctpChainValue
        );

        console.log("Base Vault deployed at:", address(vaultBase));

        vaultFactoryBase.addVault(address(vaultBase));

        aavePoolBase.setUserData(1000, 1000, 1000, 1000, 1000, 1000);

        ERC20(Baseconfig.usdcAddress).approve(address(vaultBase), 100);
        vaultBase.createOrder(address(0), 0, 1500, 43113, address(Baseconfig.usdcAddress), 100);

        address(vaultBase).call{value: 0.01 ether}("");

        vm.stopBroadcast();

        vm.selectFork(fujiFork);

        HelperConfig.NetworkConfig memory Fujiconfig = helperconfig.getConfig();

        vm.startBroadcast();

        AavePool aavePoolFuji = new AavePool();
        // console.log("Fuji AavePool deployed at:", address(aavePoolFuji));

        VaultFactory vaultFactoryFuji = new VaultFactory();

        // console.log("Fuji Vault Factory deployed at:", address(vaultFactoryFuji));

        Vault vaultFuji = new Vault(
            msg.sender, // vault owner
            address(vaultFactoryFuji), // factory
            address(aavePoolFuji), // aavePool mock
            Fujiconfig.hyperlaneMailboxAddress, // mailbox
            Fujiconfig.usdcAddress, // usdc
            Fujiconfig.tokenMessenger, // tokenMessenger
            Fujiconfig.messageTrasmitter, // messageTrasmitter
            Fujiconfig.cctpChainId, // cctpChainId
            Fujiconfig.cctpValue // cctpChainValue
        );

        console.log("Fuji Vault deployed at:", address(vaultFuji));

        address(vaultFuji).call{value: 0.01 ether}("");

        vaultFactoryFuji.addVault(address(vaultFuji));

        aavePoolFuji.setUserData(1000, 1000, 1000, 1000, 1000, 1000);

        vaultFuji.addExternalChainVault(84532, address(vaultBase));

        bytes32 OrderId = vaultFuji.generateKey(address(0), 0, 1500);

        ERC20(Fujiconfig.usdcAddress).approve(address(vaultFuji), 1000);
        vaultFuji.depositAsset(OrderId, Fujiconfig.usdcAddress, 100, 0, false);

        vm.stopBroadcast();

        vm.selectFork(baseFork);

        vm.startBroadcast();

        vaultBase.addExternalChainVault(43113, address(vaultFuji));

        vaultBase.executeOrder(address(0), 0, 1500);

        vm.stopBroadcast();

        return (vaultBase, helperconfig);
    }
}
