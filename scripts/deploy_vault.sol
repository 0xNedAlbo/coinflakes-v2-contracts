// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IVaultFactory} from "./interfaces/IVaultFactory.sol";

contract deploy_vault is Script {
    IVaultFactory public vaultFactory = IVaultFactory(0x444045c5C13C246e117eD36437303cac8E250aB0);

    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public manager = 0xDA035641151d42Aa4A25cE51de8F6e53eae0dEd7;

    uint256 public profitMaxUnlockTime = 28 days;

    function run() public {
        vm.startBroadcast();
        address vaultAddress =
            vaultFactory.deploy_new_vault(DAI, "Coinflakes Vault v2.0", "FLAKES", manager, profitMaxUnlockTime);
        console.log("Vault deployed at: ", vaultAddress);
        vm.stopBroadcast();
    }
}
