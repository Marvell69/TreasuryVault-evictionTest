// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Proposal module
/// @notice Handles creation and cancellation of treasury proposals
contract ProposalModule {

    struct Proposal {
        address proposer;
        address target;
        uint256 value;
        bytes data;
        uint256 approvals;
        uint256 executeAfter;
        bool executed;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(
        uint256 indexed id,
        address indexed proposer,
        address target,
        uint256 value,
        bytes data
    );

    event ProposalCancelled(uint256 indexed id);

    function _createProposal(
        address target,
        uint256 value,
        bytes memory data
    ) internal returns (uint256 id) {
        id = ++proposalCount;

        proposals[id] = Proposal({
            proposer: msg.sender,
            target: target,
            value: value,
            data: data,
            approvals: 0,
            executeAfter: 0,
            executed: false
        });

        emit ProposalCreated(id, msg.sender, target, value, data);
    }

    function propose(
        address target,
        uint256 value,
        bytes calldata data
    ) external virtual returns (uint256) {
        return _createProposal(target, value, data);
    }

    function cancelProposal(uint256 id) external {
        Proposal storage p = proposals[id];
        require(msg.sender == p.proposer, "ProposalModule: only proposer");
        require(!p.executed, "ProposalModule: already executed");
        delete proposals[id];
        emit ProposalCancelled(id);
    }

    function getProposal(uint256 id) external view returns (Proposal memory) {
        return proposals[id];
    }
}
