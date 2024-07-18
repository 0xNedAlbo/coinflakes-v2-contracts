// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract SimpleVaultStrategyBase_Test {
    function test_firstTry() public {
        vm.prank(users.admin);
        vm.expectRevert(IFlaixVault.OnlyAllowedForAdmin.selector);
        vault.changeAdmin(users.alice);
    }
}
