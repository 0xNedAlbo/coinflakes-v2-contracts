// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";

import {ITokenizedStrategy} from "./interfaces/ITokenizedStrategy.sol";
import {IGelatoChecker} from "./interfaces/IGelatoChecker.sol";

contract StrategyReportChecker is Ownable, IGelatoChecker {
    uint256 public maxGasPrice = 20 gwei;

    event MaxGasPriceChange(uint256 newGasPrice);

    function checker(address strategyAddress) external view returns (bool canExec, bytes memory execPayload) {
        if (tx.gasprice > maxGasPrice) return (false, bytes("max gas price exceeded"));
        if (ITokenizedStrategy(strategyAddress).isShutdown()) return (false, bytes("strategy is shutdown"));
        bytes memory payload = abi.encodeWithSelector(ITokenizedStrategy.report.selector);
        return (true, payload);
    }

    function setMaxGasPrice(uint256 newGasPrice) public onlyOwner {
        require(newGasPrice > 0, "max gas price cannot be zero");
        maxGasPrice = newGasPrice;
        emit MaxGasPriceChange(maxGasPrice);
    }
}
