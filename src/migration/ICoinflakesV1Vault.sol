// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface ICoinflakesV1Vault is IERC4626 {
    function whitelistShareholder(address) external;
    function isShareholder(address) external view returns (bool);
    function useAssets(address receiver_, uint256 amount_) external;
    function returnAssets(address sender_, uint256 amount_) external;
    function assetsInUse() external view returns (uint256);
}
