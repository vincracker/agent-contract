# AgentChat Smart Contract

This project implements a smart contract for managing chat interactions with an AI agent on the BSC blockchain. The contract allows users to purchase chat limits.

## Contract Features

### Core Functionality
- Users can purchase chat limits by sending BNB
- Configurable pricing and limit settings
- User-specific chat limit management
- Prevention of direct value transfers

### Admin Functions
- Two-step ownership transfer process with 1-day timelock
- Configure buy limit price
- Set global buy limit
- Manage individual user limits
- Batch update user limits

## Contract Parameters

- `agent`: The address that receives funds when users buy limits
- `owner`: The contract administrator address
- `pending_owner`: Address waiting to accept ownership transfer
- `ownership_transfer_timestamp`: Timestamp when ownership transfer was initiated
- `TIMELOCK_DURATION`: Duration of the timelock period (1 day)
- `buy_limit_price`: Price in BNB for purchasing chat limits (default: 1 wei)
- `buy_limit`: Number of chat interactions granted per purchase (default: 100)
- `user_chat_limit`: Mapping of user addresses to their remaining chat limits

## Security Features

- Two-step ownership transfer process with 1-day timelock
- Prevention of direct value transfers
- Checks-effects-interactions pattern implementation
- Input validation for all parameters
- Zero address checks

## Usage

### For Users
1. Send BNB equal to `buy_limit_price` to the `buy_chat_limit()` function
2. Receive `buy_limit` number of chat interactions
3. Your chat limit is tracked in the `user_chat_limit` mapping

### For Administrators
1. Deploy contract with agent address
2. Configure pricing and limits using admin functions
3. Manage individual user limits as needed
4. Transfer ownership using two-step process with timelock:
   - Initiate transfer with `transfer_ownership(new_owner)`
   - Wait for 1-day timelock period
   - New owner accepts with `accept_ownership()`
   - Optionally cancel transfer with `cancel_ownership_transfer()`
5. Check remaining timelock period with `get_remaining_timelock()`

## Events

The contract emits the following events for tracking:
- `OwnershipTransferInitiated`: When ownership transfer is initiated (includes timestamp)
- `OwnershipTransferred`: When ownership transfer is completed
- `BuyChatLimit`: When a user purchases chat limits
- `SetBuyLimitPrice`: When the price is updated
- `SetBuyLimit`: When the global limit is updated
- `SetUserLimit`: When a user's limit is updated
- `BatchSetUserLimit`: When multiple users' limits are updated

## Deployment

### Prerequisites
1. Set up your environment variables in a `.env` file:
```shell
# Required
PRIVATE_KEY=0x...    # Your deployer's private key
AGENT_ADDRESS=0x...  # The address that will receive funds

# For BSC networks
BSC_RPC_URL=https://...  # Optional, defaults to public RPC
BSCSCAN_API_KEY=...      # For contract verification
```

### Local Development Network
1. Start a local Hardhat node:
```shell
npx hardhat node
```

2. Deploy to local network:
```shell
npx hardhat ignition deploy ./ignition/modules/AgentChat.ts --network localhost
```

### BSC Testnet
1. Make sure you have BNB in your deployer account on BSC Testnet
2. Deploy to BSC Testnet:
```shell
npx hardhat ignition deploy ./ignition/modules/AgentChat.ts --network bscTestnet
```

### BSC Mainnet
1. Make sure you have BNB in your deployer account on BSC Mainnet
2. Deploy to BSC Mainnet:
```shell
npx hardhat ignition deploy ./ignition/modules/AgentChat.ts --network bsc
```

### Contract Verification
After deployment, verify your contract on BscScan:
```shell
npx hardhat verify --network bscTestnet <DEPLOYED_CONTRACT_ADDRESS> <AGENT_ADDRESS>
```

Note: 
- Make sure you have sufficient BNB in your deployer account for the target network
- The contract will be deployed with the agent address specified in your environment variables
- Contract verification requires a BscScan API key
