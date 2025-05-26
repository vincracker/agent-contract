# AgentChat Smart Contract

This project implements a smart contract for managing chat interactions with an AI agent on the Ethereum blockchain. The contract allows users to purchase chat limits and implements a secure withdrawal pattern for fund management.

## Contract Features

### Core Functionality
- Users can purchase chat limits by sending ETH
- Secure fund management with withdrawal pattern
- Configurable pricing and limit settings
- User-specific chat limit management
- Prevention of direct value transfers

### Admin Functions
- Two-step ownership transfer process
- Configure buy limit price
- Set global buy limit
- Manage individual user limits
- Batch update user limits

### Agent Functions
- Withdraw specific amount of funds
- Withdraw all accumulated funds
- View contract balance

## Contract Parameters

- `agent`: The address that can withdraw funds from the contract
- `owner`: The contract administrator address
- `pendingOwner`: Address waiting to accept ownership transfer
- `buy_limit_price`: Price in ETH for purchasing chat limits (default: 0.1 ETH)
- `buy_limit`: Number of chat interactions granted per purchase (default: 100)
- `user_chat_limit`: Mapping of user addresses to their remaining chat limits
- `totalFunds`: Total amount of funds accumulated in the contract

## Security Features

- Two-step ownership transfer process
- Prevention of direct value transfers
- Checks-effects-interactions pattern implementation
- Input validation for all parameters
- Secure withdrawal pattern
- Zero address checks
- Balance verification before withdrawals

## Usage

### For Users
1. Send ETH equal to `buy_limit_price` to the `buy_chat_limit()` function
2. Receive `buy_limit` number of chat interactions
3. Your chat limit is tracked in the `user_chat_limit` mapping

### For Administrators
1. Deploy contract with agent address
2. Configure pricing and limits using admin functions
3. Manage individual user limits as needed
4. Transfer ownership using two-step process if needed

### For Agents
1. Monitor accumulated funds using `getContractBalance()`
2. Withdraw specific amount using `withdrawFunds(amount)`
3. Withdraw all funds using `withdrawAllFunds()`

## Events

The contract emits the following events for tracking:
- `OwnershipTransferInitiated`: When ownership transfer is initiated
- `OwnershipTransferred`: When ownership transfer is completed
- `BuyChatLimit`: When a user purchases chat limits
- `SetBuyLimitPrice`: When the price is updated
- `SetBuyLimit`: When the global limit is updated
- `SetUserLimit`: When a user's limit is updated
- `BatchSetUserLimit`: When multiple users' limits are updated
- `WithdrawFunds`: When funds are withdrawn

## Development

This project uses Hardhat for development and testing. Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/AgentChat.ts
```
