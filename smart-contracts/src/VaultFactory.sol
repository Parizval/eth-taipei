// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Vault} from "./Vault.sol";

contract VaultFactory {
    event VaultCreated(address indexed vaultAddress, address indexed owner);
    event CrossChainTransfer(address indexed vaultAddress, address indexed token, uint256 amount);

    error InvalidVault();
    error VaultAlreadyExists(address vaultAddress);


    address public immutable owner;

    address public immutable aavePool;

    address public immutable mailbox;

    address public immutable usdc;
    address public immutable tokenMessenger;

    address public immutable wormholeRelayer;
    address public immutable wormholeTokenBridge;
    address public immutable wormholeCore;

    uint32 public immutable destinationCCTPChainId;
    uint32 public immutable destinationCCTPChainValue;

    constructor(address _aavePool, address _mailbox, address _usdc, address _tokenMessenger, address _wormholeRelayer, address _wormholeTokenBridge, address _wormholeCore, uint32 _destinationCCTPChainId, uint32 _destinationCCTPChainValue) {
        owner = msg.sender;

        aavePool = _aavePool;
        mailbox = _mailbox;
        usdc = _usdc;
        tokenMessenger = _tokenMessenger;
        wormholeRelayer = _wormholeRelayer;
        wormholeTokenBridge = _wormholeTokenBridge;
        wormholeCore = _wormholeCore;
        destinationCCTPChainId = _destinationCCTPChainId;
        destinationCCTPChainValue = _destinationCCTPChainValue;

    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    mapping(address => address) public vaults;

    mapping(uint32 => uint16) public worldChainId;

    function createVault() external returns (address) {
        if (vaults[msg.sender] != address(0)) {
            revert VaultAlreadyExists(vaults[msg.sender]);
        }

        Vault vault = new Vault(
            msg.sender,
            aavePool,
            mailbox,
            usdc,
            tokenMessenger,
            wormholeRelayer,
            wormholeTokenBridge,
            wormholeCore,
            destinationCCTPChainId,
            destinationCCTPChainValue
        );

        vaults[msg.sender] = address(vault);

        emit VaultCreated(address(vault), msg.sender);

        return address(vault);
    }

    function emitCrossChainTransfer(address _owner, address _token, uint256 _amount) external {
        address vault = vaults[_owner];

        if (vault != msg.sender) {
            revert InvalidVault();
        }

        emit CrossChainTransfer(vault, _token, _amount);
    }

    function setWormholeChainId(uint32 _chainId, uint16 _worldChainId) external onlyOwner {
        worldChainId[_chainId] = _worldChainId;
    }

    function getWormholeChainId(uint32 _chainId) external view returns (uint16) {
        return worldChainId[_chainId];
    }

    function getVaultAddress(address _owner) external view returns (address) {
        return vaults[_owner];
    }
}
