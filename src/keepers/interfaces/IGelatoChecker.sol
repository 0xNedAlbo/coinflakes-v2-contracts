// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

interface IGelatoChecker {
    function checker(address) external view returns (bool canExec, bytes memory execPayload);
}
