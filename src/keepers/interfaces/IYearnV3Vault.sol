// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

interface IYearnV3Vault {
    function process_report(address strategy) external returns (uint256 profit, uint256 loss);
    function isShutdown() external view returns (bool);
}
