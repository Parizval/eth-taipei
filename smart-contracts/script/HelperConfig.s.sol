// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

abstract contract ChainIdConfiguration {
    uint256 public constant BASE_SEPOLIA = 84532;

    // uint256 public constant BASE_MAINNET = 84531;

    uint256 public constant FUJI = 43113;

    uint256 public constant SEPOLIA = 11155111;
}

contract HelperConfig is Script, ChainIdConfiguration {
    struct NetworkConfig {
        address hyperlaneMailboxAddress;
        address usdcAddress;
        address tokenMessenger;
        address wormholeRelayer;
        address tokenBridge;
        address wormhole;
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
            usdcAddress: 0x1234567890123456789012345678901234567890,
            tokenMessenger: 0x1234567890123456789012345678901234567890,
            wormholeRelayer: 0x93BAD53DDfB6132b0aC8E37f6029163E63372cEE,
            tokenBridge: 0x86F55A04690fd7815A3D802bD587e83eA888B239,
            wormhole: 0x79A1027a6A159502049F10906D333EC57E95F083,
            cctpChainId: 0,
            cctpValue: 1
        });
    }

    function getFujiConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            hyperlaneMailboxAddress: 0x5b6CFf85442B851A8e6eaBd2A4E4507B5135B3B0,
            usdcAddress: 0x1234567890123456789012345678901234567890,
            tokenMessenger: 0x1234567890123456789012345678901234567890,
            wormholeRelayer: 0xA3cF45939bD6260bcFe3D66bc73d60f19e49a8BB,
            tokenBridge: 0x61E44E506Ca5659E6c0bba9b678586fA2d729756,
            wormhole: 0x7bbcE28e64B3F8b84d876Ab298393c38ad7aac4C,
            cctpChainId: 0,
            cctpValue: 1
        });
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            hyperlaneMailboxAddress: 0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766,
            usdcAddress: 0x1234567890123456789012345678901234567890,
            tokenMessenger: 0x1234567890123456789012345678901234567890,
            wormholeRelayer: 0x7B1bD7a6b4E61c2a123AC6BC2cbfC614437D0470,
            tokenBridge: 0xDB5492265f6038831E89f495670FF909aDe94bd9,
            wormhole: 0x4a8bc80Ed5a4067f1CCf107057b8270E0cC11A78,
            cctpChainId: 0,
            cctpValue: 1
        });
    }
}
