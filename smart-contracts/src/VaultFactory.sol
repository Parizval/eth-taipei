// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Vault} from "./Vault.sol";

contract VaultFactory {
    event VaultCreated(address indexed vaultAddress, address indexed owner);
    event CrossChainTransfer(address indexed vaultAddress, address indexed token, uint amount);

    error InvalidVault();

    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    mapping(address => address) public vaults;

    mapping(uint32 => uint16) public worldChainId;

    function createVault() external returns (address) {
        if (vaults[msg.sender] != address(0)) {
            revert("Vault already exists");
        }

        Vault vault =
            new Vault(msg.sender, msg.sender, msg.sender, msg.sender, msg.sender, msg.sender, msg.sender, msg.sender, 8, 9);

        vaults[msg.sender] = address(vault);

        emit VaultCreated(address(vault), msg.sender);

        return address(vault);
    }

    function emitCrossChainTransfer(address _owner, address _token, uint _amount) external {
        address vault = vaults[_owner];

        if (vault != msg.sender) {
            revert InvalidVault();
        }

        emit CrossChainTransfer(vault, _token, _amount);

    }


    function setWorldChainId(uint32 _chainId, uint16 _worldChainId) external onlyOwner {
        worldChainId[_chainId] = _worldChainId;
    }

    function getWorldChainId(uint32 _chainId) external view returns (uint16) {
        return worldChainId[_chainId];
    }

    function getVaultAddress(address _owner) external view returns (address) {
        return vaults[_owner];
    }
}
