/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "@openzeppelin-contracts/contracts/utils/math/Math.sol";
import "@openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "@test/utils/interfaces/IWETH9.sol";
import "@test/utils/interfaces/ICurveRouterNG.sol";

contract CurveSwaps is Test {
    using Math for uint256;

    address wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IWETH9 public WETH = IWETH9(payable(wethAddress));
    IERC20 public DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    address public tricryptoUsdcCurvePool = 0x7F86Bf177Dd4F3494b841a37e810A34dD56c829B;
    address public threePoolCurvePool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;

    ICurveRouterNG public curveRouter = ICurveRouterNG(0x16C6521Dff6baB339122a0FE25a9116693265353);

    function fundWithDai(address receiver, uint256 daiAmount) public payable {
        // wETH is 2, USDC is 0
        address[11] memory routes = [
            address(WETH),
            tricryptoUsdcCurvePool,
            address(USDC),
            threePoolCurvePool,
            address(DAI),
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000
        ];
        uint256[5][5] memory swapParams = [
            [uint256(2), 0, 1, 3, 3],
            [uint256(1), 0, 1, 1, 3],
            [uint256(0), 0, 0, 0, 0],
            [uint256(0), 0, 0, 0, 0],
            [uint256(0), 0, 0, 0, 0]
        ];
        address[5] memory pools = [
            tricryptoUsdcCurvePool,
            threePoolCurvePool,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000
        ];
        address[5] memory empty = [
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000
        ];

        uint256 inAmount = curveRouter.get_dx(routes, swapParams, daiAmount, pools, empty, empty);
        inAmount = inAmount.mulDiv(11e10, 1e11); // Account for 10% slippage
        vm.deal(address(this), inAmount);
        WETH.deposit{value: inAmount}();
        WETH.approve(address(curveRouter), inAmount);
        curveRouter.exchange(routes, swapParams, inAmount, daiAmount, empty, receiver);
    }
}
