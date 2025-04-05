// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IFactory {
    function getWormholeChainId(uint32 _chainId) external view returns (uint16);

    function getReverseWormholeChainId(uint16 _wormholeChainId) external view returns (uint32);

    function emitCrossChainTransfer(address _owner, address _token, uint256 _amount) external;

    function emitOrderCreation(address _owner, uint16 conditionId, uint256 conditionAmount) external;
}
