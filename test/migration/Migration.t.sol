// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {CurveSwaps} from "@test/utils/CurveSwaps.sol";

import {CoinflakesV2Migration} from "@src/migration/CoinflakesV2Migration.sol";
import {ICoinflakesV1Vault} from "@src/migration/ICoinflakesV1Vault.sol";

contract MigrationTest is Test {
    using Math for uint256;

    address public manager = 0xDA035641151d42Aa4A25cE51de8F6e53eae0dEd7;
    address[3] public holders = [
        0x76A08F0D284726Eb6246474686BBa84eF5bFfAeB,
        0xF81f557cD5c91fa8c339f47ec60DEE0ca2BD291f,
        0x7c46713490E379f515A182d8a5a36deC9d99Be6A
    ];

    CurveSwaps public swaps = new CurveSwaps();
    CoinflakesV2Migration public migration;

    ICoinflakesV1Vault public vaultV1 = ICoinflakesV1Vault(0x430fD367dBbaebDAe682060e0fd2b2B1583E0639);
    IERC4626 public vaultV2 = IERC4626(0x254bd33E2f62713F893F0842C99E68f855cDa315);
    IERC20 public DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    modifier withNoAssetsInUse() {
        uint256 assetsInUse = vaultV1.assetsInUse();
        if (assetsInUse > 0) {
            swaps.fundWithDai(manager, assetsInUse);
            assertGe(DAI.balanceOf(manager), assetsInUse, "funding of manager address failed");
            vm.startPrank(manager);
            DAI.approve(address(vaultV1), assetsInUse);
            vaultV1.returnAssets(manager, assetsInUse);
            vm.stopPrank();
        }
        assertEq(vaultV1.assetsInUse(), 0);
        _;
    }

    modifier withAssetsInUse() {
        uint256 assetsInUse = vaultV1.assetsInUse();
        if (assetsInUse == 0) {
            swaps.fundWithDai(address(vaultV1), 10000 ether);
            vaultV1.useAssets(manager, 10000 ether);
        }
        assertGe(vaultV1.assetsInUse(), 10000 ether);
        _;
    }

    function setUp() public {
        // Setup contract
        vm.prank(manager);
        migration = new CoinflakesV2Migration();
        assertEq(migration.owner(), manager, "manager not contract owner");
    }

    function test_migrate_fails() public withAssetsInUse {
        if (vaultV1.totalSupply() < 100) return;
        address holder = holders[0];
        vm.startPrank(holder);
        uint256 redeemable = vaultV1.maxRedeem(holder);
        vaultV1.approve(address(migration), redeemable);
        vm.expectRevert(bytes("assets still in use in old vault"));
        migration.migrate(redeemable, holder);
        vm.stopPrank();
    }

    function test_migrate() public withNoAssetsInUse {
        if (vaultV1.totalSupply() < 100) return;
        for (uint256 i = 0; i < 3; i++) {
            address holder = holders[i];
            vm.startPrank(holder);
            uint256 redeemable = vaultV1.maxRedeem(holder);
            if (redeemable < 100) continue;
            vaultV1.approve(address(migration), redeemable);
            migration.migrate(redeemable, holder);
            vm.stopPrank();
        }
        console.log("Total supply: ", vaultV1.totalSupply());
    }

    function test_withdrawAssets() public {
        uint256 balanceBefore = DAI.balanceOf(manager);
        swaps.fundWithDai(address(migration), 1000 ether);
        vm.prank(manager);
        migration.withdrawAssets(address(DAI), 1000 ether, manager);
        assertEq(DAI.balanceOf(manager), balanceBefore + 1000 ether);
    }

    function test_withdrawAssets_fails_called_by_unauthorized_user() public {
        swaps.fundWithDai(address(migration), 1000 ether);
        vm.prank(holders[1]);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        migration.withdrawAssets(address(DAI), 1000 ether, holders[1]);
    }
}
