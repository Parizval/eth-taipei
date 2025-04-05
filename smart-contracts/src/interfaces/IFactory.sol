// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IFactory {
    function getWormholeChainId(uint32 _chainId) external view returns (uint16);

    function emitCrossChainTransfer(address _owner, address _token, uint256 _amount) external;
}
