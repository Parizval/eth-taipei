// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

abstract contract ChainIdConfiguration {
    uint256 public constant BASE_SEPOLIA = 84532;

    // uint256 public constant BASE_MAINNET = 84531;

    uint256 public constant FUJI = 43113;

}

contract HelperConfig is Script, ChainIdConfiguration {
    struct NetworkConfig {
        address hyperlaneMailboxAddress;
        address usdcAddress;
        address tokenMessenger;
        address messageTrasmitter;
        uint32 cctpChainId;
        uint32 cctpValue;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[BASE_SEPOLIA] = getBaseSepoliaConfig();
        networkConfigs[FUJI] = getFujiConfig();
    }

    function getNetworkConfig() public view returns (NetworkConfig memory) {
        if (block.chainid == BASE_SEPOLIA) {
            return networkConfigs[BASE_SEPOLIA];
        } else if (block.chainid == FUJI) {
            return networkConfigs[FUJI];
        } else {
            revert("Unsupported chain");
        }
    }

    function getConfig() public view returns (NetworkConfig memory) {
        return networkConfigs[block.chainid];
    }

    function getBaseSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            hyperlaneMailboxAddress: 0x6966b0E55883d49BFB24539356a2f8A673E02039,
            usdcAddress: 0x036CbD53842c5426634e7929541eC2318f3dCF7e,
            tokenMessenger: 0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA,
            messageTrasmitter : 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275,
            cctpChainId: 43113,
            cctpValue: 1
        });
    }

    function getFujiConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            hyperlaneMailboxAddress: 0x6895d3916B94b386fAA6ec9276756e16dAe7480E,
            usdcAddress: 0x5425890298aed601595a70AB815c96711a31Bc65,
            tokenMessenger: 0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA,
            messageTrasmitter : 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275,
            cctpChainId: 84532,
            cctpValue: 6
        });
    }

}
