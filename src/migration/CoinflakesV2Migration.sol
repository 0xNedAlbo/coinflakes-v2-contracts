// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ICoinflakesV1Vault} from "./ICoinflakesV1Vault.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CoinflakesV2Migration is Ownable {
    using SafeERC20 for IERC4626;
    using SafeERC20 for ICoinflakesV1Vault;
    using SafeERC20 for IERC20;

    ICoinflakesV1Vault public vaultV1 = ICoinflakesV1Vault(0x430fD367dBbaebDAe682060e0fd2b2B1583E0639);
    IERC4626 public vaultV2 = IERC4626(0x254bd33E2f62713F893F0842C99E68f855cDa315);
    IERC20 public asset;

    address public lastHolder = 0x7c46713490E379f515A182d8a5a36deC9d99Be6A;

    event Migrated(uint256 sharesV1, uint256 sharesV2, uint256 depositedAssets, address indexed receiver);

    constructor() {
        require(vaultV1.asset() == vaultV2.asset(), "assets mismatched");
        asset = IERC20(vaultV1.asset());
    }

    function migrate(uint256 sharesV1, address receiver) public {
        require(vaultV1.assetsInUse() == 0, "assets still in use in old vault");
        require(sharesV1 > 0, "must redeem more than zero shares");
        vaultV1.safeTransferFrom(msg.sender, address(this), sharesV1);
        uint256 maxRedeemable = vaultV1.maxRedeem(address(this));
        if (sharesV1 > maxRedeemable) sharesV1 = maxRedeemable;
        uint256 withdrawn = vaultV1.redeem(sharesV1, address(this), address(this));
        if (vaultV1.balanceOf(address(this)) > 0) {
            vaultV1.transfer(receiver, vaultV1.balanceOf(address(this)));
        }
        uint256 assets = asset.balanceOf(address(this));
        require(assets >= withdrawn, "not enough assets withdrawn from old vault");
        asset.approve(address(vaultV2), assets);
        uint256 sharesV2 = vaultV2.deposit(assets, receiver);
        emit Migrated(sharesV1, sharesV2, assets, receiver);
    }

    function withdrawAssets(address tokenAddr, uint256 amount, address receiver) public onlyOwner {
        IERC20 token = IERC20(tokenAddr);
        token.transfer(receiver, amount);
    }
}
