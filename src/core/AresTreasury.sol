// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../../src/libraries/SignatureLib.sol";

contract AresTreasury {

    using SignatureLib for bytes32;

    struct Proposal {
        address target;
        uint256 value;
        bytes data;
        uint256 approvals;
        uint256 executeAfter;
        bool executed;
    }

    uint256 public proposalCount;
    uint256 public constant TIMELOCK = 1 hours;
    uint256 public requiredApprovals;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public isSigner;
    mapping(uint256 => mapping(address => bool)) public approved;

    constructor(address[] memory signers, uint256 _required) {

        requiredApprovals = _required;

        for(uint i = 0; i < signers.length; i++){
            isSigner[signers[i]] = true;
        }
    }

    receive() external payable {}


    function propose(address target, uint256 value, bytes calldata data)
        external
        returns(uint256)
    {
        proposalCount++;

        proposals[proposalCount] = Proposal({
            target: target,
            value: value,
            data: data,
            approvals: 0,
            executeAfter: 0,
            executed: false
        });

        return proposalCount;
    }

    function approve(uint256 id, bytes memory sig) external {

        bytes32 hash = keccak256(abi.encodePacked(id));

        bytes32 ethHash = SignatureLib.toEthSignedMessageHash(hash);

        address signer = SignatureLib.recoverSigner(ethHash, sig);

        require(isSigner[signer], "invalid signer");

        require(!approved[id][signer], "Already approved");

        Proposal storage p = proposals[id];

        approved[id][signer] = true;

        p.approvals++;

        if(p.approvals >= requiredApprovals && p.executeAfter == 0){
            p.executeAfter = block.timestamp + TIMELOCK;
        }
    }

    function execute(uint256 id) external {

        Proposal storage p = proposals[id];

        require(!p.executed, "already executed");

        require(p.approvals >= requiredApprovals, "Not enough approvals");

        require(block.timestamp >= p.executeAfter, "timelock");

        p.executed = true;

        (bool success,) = p.target.call{value:p.value}(p.data);

        require(success, "Transaction failed");
    }
}