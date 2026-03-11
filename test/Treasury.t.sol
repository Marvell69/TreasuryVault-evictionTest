// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {AresTreasury} from "../src/core/AresTreasury.sol";
import {SignatureLib} from "../src/libraries/SignatureLib.sol";

contract TreasuryTest is Test {

    AresTreasury treasury;

    address Marvel = vm.addr(1);
    address Richard = vm.addr(2);
    address Bob = vm.addr(3);

   

    function setUp() public {

        Marvel = vm.addr(1);
        Richard = vm.addr(2);
        Bob = vm.addr(3);

        address[] memory signers = new address[](3);
        signers[0] = Marvel;
        signers[1] = Richard;
        signers[2] = Bob;

        treasury = new AresTreasury(signers,2);

        vm.deal(address(treasury),1 ether);
    }



    function getSig(uint256 key, uint256 id) internal returns(bytes memory){

        bytes32 hash = keccak256(abi.encodePacked(id));

        bytes32 ethHash = SignatureLib.toEthSignedMessageHash(hash);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, ethHash);

        return abi.encodePacked(r,s,v);
    }

    function approveByTwo(uint256 id) internal {

        treasury.approve(id,getSig(1,id));
        treasury.approve(id,getSig(2,id));
    }

    function dummy() public {}

    function testProposalLifecycle() public {

        uint256 id = treasury.propose(
            address(this),
            0,
            abi.encodeWithSignature("dummy()")
        );

        approveByTwo(id);

        vm.warp(block.timestamp + 1 days + 1);

        treasury.execute(id);
    }

    function testSignatureVerification() public {

        uint256 id = treasury.propose(address(this),0,"");

        treasury.approve(id,getSig(1,id));
    }

  

    function testInvalidSignature() public {

        uint256 id = treasury.propose(address(this),0,"");

        vm.expectRevert("Authorization: invalid signer");

        treasury.approve(id,getSig(9,id));
    }

    function testDoubleApproval() public {

        uint256 id = treasury.propose(address(this),0,"");

        bytes memory sig = getSig(1,id);

        treasury.approve(id,sig);

        vm.expectRevert("Already approved");

        treasury.approve(id,sig);
    }

    function testExecuteBeforeApprovals() public {

        uint256 id = treasury.propose(address(this),0,"");

        vm.expectRevert("Not enough approvals");

        treasury.execute(id);
    }

    function testPrematureExecution() public {

        uint256 id = treasury.propose(address(this),0,"");

        approveByTwo(id);

        vm.expectRevert("AresTreasury: timelock");

        treasury.execute(id);
    }

    
    
    function testInvalidSignerAttack() public {

        uint256 id = treasury.propose(address(this),0,"");

        vm.expectRevert();

        treasury.approve(id,getSig(99,id));
    }

    function testReentrancyAttack() public {

        Malicious attacker = new Malicious(address(treasury));

        uint256 id = treasury.propose(
            address(attacker),
            0,
            abi.encodeWithSignature("attack()")
        );

        approveByTwo(id);

        vm.warp(block.timestamp + 1 days + 1);

        treasury.execute(id);
    }
}

contract Malicious {

    AresTreasury treasury;

    constructor(address _treasury){
        treasury = AresTreasury(payable(_treasury));
    }

    function attack() public {

        try treasury.execute(1) {

        } catch {

        }
    }
}