// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Interface describing the high‑level treasury API used by modules
interface ITreasury {
    function propose(address target, uint256 value, bytes calldata data) external returns (uint256);
    function approve(uint256 proposalId, bytes calldata signature) external;
    function execute(uint256 proposalId) external;
}
