// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "@test/utils/Swaps.sol";
import "@src/strategies/SimpleVaultStrategy.sol";

contract SimpleVaultStrategyBase_Test is Test {
    SimpleVaultStrategy public strategy;

    IERC4626 SDAI = IERC4626(0x83F20F44975D03b1b09e64809B757c47f942BEeA);
    IERC20 DAI;

    function setUp() public {
        string memory forkUrl = vm.envString("MAINNET_RPC_URL");
        vm.createSelectFork(forkUrl);

        address admin = vm.addr(1);
        vm.deal(admin, 1.1 ether);
        Swaps swaps = new Swaps();
        DAI = swaps.DAI();

        vm.startPrank(admin);
        swaps.swapToDai{value: 1 ether}();
        uint256 daiBalance = DAI.balanceOf(admin);
        DAI.approve(address(SDAI), daiBalance);
        SDAI.deposit(daiBalance, address(admin));
    }

    function test_firstTry() public {}
}
