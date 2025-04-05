// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {AavePool} from "../src/AaveMock.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract VaultTest is Test {
    Vault public vault;
    VaultFactory public vaultFactory;
    AavePool public aavePool;
    ERC20 public usdc;

    function setUp() public {
        vm.startPrank(address(1));

        aavePool = new AavePool();

        vaultFactory = new VaultFactory();

        vault =
            new Vault(address(1), address(vaultFactory), address(aavePool), address(0), address(0), address(0), 0, 0);

        usdc = new MockERC20("USDC", "USDC");

        vm.stopPrank();
    }

    function testOrderCreationWithSameExecution() public {
        vm.startPrank(address(1));

        vaultFactory.addVault(address(vault));

        aavePool.setUserData(1000, 1000, 1000, 1000, 1000, 1000);

        usdc.approve(address(vault), 200);

        vault.createOrder(address(0), 0, 1500, uint32(block.chainid), address(usdc), 100);

        assertEq(usdc.balanceOf(address(vault)), 100);
        assertEq(usdc.balanceOf(address(aavePool)), 0);

        bytes32 orderId = vault.generateKey(address(0), 0, 1500);

        vault.depositAsset(orderId, address(usdc), 100, 0, false);
        assertEq(usdc.balanceOf(address(vault)), 200);

        vm.stopPrank();

        vm.prank(address(2));
        vault.executeOrder(address(0), 0, 1500);

        assertEq(usdc.balanceOf(address(2)), 100); // TIP
        assertEq(usdc.balanceOf(address(aavePool)), 100);

        assertEq(usdc.balanceOf(address(vault)), 0);
    }
}
