// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AavePool {
    error InvalidInterestRateMode();

    address public immutable owner;

    uint256 public totalCollateralBase;
    uint256 public totalDebtBase;
    uint256 public availableBorrowsBase;
    uint256 public currentLiquidationThreshold;
    uint256 public ltv;
    uint256 public healthFactor;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external {
        if (referralCode != 0) {
            revert InvalidInterestRateMode();
        }
        if (onBehalfOf == msg.sender) {
            revert InvalidInterestRateMode();
        }

        IERC20(asset).transferFrom(msg.sender, address(this), amount);
    }

    function repay(address asset, uint256 amount, uint256 interestRateMode, address onBehalfOf)
        external
        returns (uint256)
    {
        if (interestRateMode != 2) {
            revert InvalidInterestRateMode();
        }

        if (onBehalfOf == msg.sender) {
            revert InvalidInterestRateMode();
        }

        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        return 0;
    }

    function setUserData(
        uint256 _totalCollateralBase,
        uint256 _totalDebtBase,
        uint256 _availableBorrowsBase,
        uint256 _currentLiquidationThreshold,
        uint256 _ltv,
        uint256 _healthFactor
    ) external onlyOwner {
        totalCollateralBase = _totalCollateralBase;
        totalDebtBase = _totalDebtBase;
        availableBorrowsBase = _availableBorrowsBase;
        currentLiquidationThreshold = _currentLiquidationThreshold;
        ltv = _ltv;
        healthFactor = _healthFactor;
    }

    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return
            (totalCollateralBase, totalDebtBase, availableBorrowsBase, currentLiquidationThreshold, ltv, healthFactor);
    }

    function withdraw(address asset, uint256 amount, address to) external onlyOwner {
        IERC20(asset).transfer(to, amount);
    }
}
