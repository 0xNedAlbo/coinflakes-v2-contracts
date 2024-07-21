// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/BaseTest.t.sol";

import "@src/strategies/SimpleVaultStrategy.sol";

contract SimpleVaultStrategyBase_Test is BaseTest {
    SimpleVaultStrategy public strategy;

    IERC4626 SDAI = IERC4626(0x83F20F44975D03b1b09e64809B757c47f942BEeA);

    function setUp() public virtual override {
        super.setUp();
        strategy = new SimpleVaultStrategy("Test Vault", "TEST", SDAI, DAI);
    }

    function test_deposit_10000_DAI() public whenInvestorHasDAI(10000e18) {
        vm.startPrank(investor1);
        DAI.approve(address(strategy), 10000e18);
        strategy.deposit(10000e18, investor1);
        vm.stopPrank();
    }
}
