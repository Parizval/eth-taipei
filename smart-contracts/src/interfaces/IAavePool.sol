// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface AavePool  {
    
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external ;

    function repay(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    address onBehalfOf
) external returns (uint256);


}