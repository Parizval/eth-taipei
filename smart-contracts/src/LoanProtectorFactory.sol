// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Vault} from "./Vault.sol";

contract VaultFactory {
    mapping(address => address) public loanToProtector;
}
