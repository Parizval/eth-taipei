// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Vault} from "./Vault.sol";

contract VaultFactory {
    event VaultCreated(address indexed vaultAddress, address indexed owner);

    mapping(address => address) public vaults;

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

    function getVaultAddress(address _owner) external view returns (address) {
        return vaults[_owner];
    }
}
