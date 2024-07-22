// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "@openzeppelin-contracts/contracts/interfaces/IERC4626.sol";
import "@openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import "@tokenized-strategy/TokenizedStrategy.sol";

contract SimpleVaultStrategy is TokenizedStrategy {
    IERC4626 public vault;

    constructor(string memory name_, string memory symbol_, IERC4626 vault_, IERC20 asset_)
        
    {
        vault = vault_;
    }

    function totalAssets() public view virtual override returns (uint256) {
        return vault.convertToAssets(vault.balanceOf(address(this)));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        if (to == address(0x0)) {
            uint256 underlyingAmount = convertToAssets(amount);
            vault.withdraw(underlyingAmount, address(this), address(this));
        }
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        if (from == address(0x0)) {
            IERC20 asset = IERC20(vault.asset());
            uint256 underlyingBalance = asset.balanceOf(address(this));
            asset.approve(address(vault), underlyingBalance);
            vault.deposit(underlyingBalance, address(this));
        }
        super._afterTokenTransfer(from, to, amount);
    }
}
