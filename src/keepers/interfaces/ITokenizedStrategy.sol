// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

interface ITokenizedStrategy {
    function isShutdown() external view returns (bool);
    function report() external returns (uint256 profit, uint256 loss);
}
