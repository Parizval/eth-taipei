// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IFactory {
   
    function getWorldChainId(uint32 _chainId) external view returns (uint16);

}