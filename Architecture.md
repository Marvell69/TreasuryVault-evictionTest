## Architecture Overview
This project implements a simple treasury system that allows a group of trusted signers to manage funds together. this improves security and prevents a single point of faliure.

## Main Components
The project is split into small modules to keep it neat adn organized:

**Signature Library**
This library contains helper functions used to recover the address that signed a message.

**Authorization Module**: This module manages who is allowed to approve proposals, it stores:the list of authorized signers, how many approvals are required, which signer has already approved a proposal, It also prevents the same signer from approving a proposal twice.

**Proposal Module**: This module handles the creation and management of proposals.Each proposal contains:
target contract address,ETH value to send, call data, number of approvals, execution time and status.
Users can:
- create proposals
- cancel proposals they created

**TimeLock Module**: This module handles the delay between approval and execution.
"TIMELOCK = 1 day"
Once enough signers approve a proposal, it must wait 1 day before it can be executed, this delay gives time to review the transaction and react if something is wrong.

**AresTreasury**: This is the main contract that connects all modules it does the following:Deposit ETH, Create proposal, Approve proposal, Execute proposal.

**Security Features**: The treasury includes several basic protections:
-Multi-Signature Approvals
    More than one signer must approve a proposal.

-Double Approval Protection
    A signer cannot approve the same proposal twice.

-Timelock Protection
    Proposals cannot execute immediately after approval.

-Execution Protection
    A proposal cannot be executed more than once.