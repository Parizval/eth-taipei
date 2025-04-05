// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AavePool} from "./interfaces/IAavePool.sol";

contract AaveFetch {
    address public aavePool;

    uint256 public totalCollateralBase;
    uint256 public totalDebtBase;
    uint256 public ltv;
    uint256 public healthFactor;

    constructor(address _aavePool) {
        aavePool = _aavePool;
    }

    function getAaveData(address owner) external {
        (totalCollateralBase, totalDebtBase,,, ltv, healthFactor) = AavePool(aavePool).getUserAccountData(owner);
    }
}
