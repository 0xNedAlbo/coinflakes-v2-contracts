// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/utils/CurveSwaps.sol";

contract BaseTest is CurveSwaps {
    address public admin = vm.addr(1);
    address public investor1 = vm.addr(2);

    function setUp() public virtual {
        setUp_fundUsers();
    }

    function setUp_fundUsers() public virtual {}

    modifier whenInvestorHasDAI(uint256 daiAmount) {
        deal(investor1, 20 ether);
        vm.startPrank(investor1);
        fundWithDai(investor1, daiAmount);
        assertGe(DAI.balanceOf(investor1), 10000);
        vm.stopPrank();
        _;
    }
}
