// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICurveRouterNG {
    function exchange(
        address[11] memory routes,
        uint256[5][5] memory swapParams,
        uint256 amount,
        uint256 expected,
        address[5] memory pools,
        address receiver
    ) external;
}
