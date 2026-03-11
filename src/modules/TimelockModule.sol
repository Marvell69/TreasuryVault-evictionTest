// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Timelock module
/// @notice Defines a constant delay used by the treasury
abstract contract TimelockModule {
    /// @notice delay applied once proposals reach quorum
    uint256 public constant TIMELOCK = 1 days;
}
