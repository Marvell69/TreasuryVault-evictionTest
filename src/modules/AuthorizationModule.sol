// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Simple Authorization Module
/// @notice Keeps track of who can approve proposals
contract AuthorizationModule {

    // addresses allowed to approve proposals
    mapping(address => bool) public isSigner;

    // how many approvals are needed
    uint256 public requiredApprovals;

    // tracks who approved each proposal
    mapping(uint256 => mapping(address => bool)) public approved;

    event ProposalApproved(uint256 proposalId, address signer);

    constructor(address[] memory signers, uint256 approvalsNeeded) {

        requiredApprovals = approvalsNeeded;

        // add all signers
        for (uint i = 0; i < signers.length; i++) {
            isSigner[signers[i]] = true;
        }
    }

    function approve(uint256 proposalId) public {

        require(isSigner[msg.sender], "Not allowed");

        require(!approved[proposalId][msg.sender], "Already approved");

        approved[proposalId][msg.sender] = true;

        emit ProposalApproved(proposalId, msg.sender);
    }
}
