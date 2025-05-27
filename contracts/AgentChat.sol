// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract AgentChat {
    address payable public agent;
    address public owner;
    address public pending_owner;
    uint256 public buy_limit_price = 1 wei; // reduced default price for testing
    uint256 public buy_limit = 100; // default limit
    uint256 public ownership_transfer_timestamp;

    // user chat limit mapping
    mapping(address => uint256) public user_chat_limit;

    // timelock duration for ownership transfer
    uint256 public constant TIMELOCK_DURATION = 1 days;

    event OwnershipTransferInitiated(
        address indexed previous_owner,
        address indexed new_owner,
        uint256 timestamp
    );

    event OwnershipTransferred(
        address indexed previous_owner,
        address indexed new_owner
    );

    event BuyChatLimit(address indexed user, uint256 amount);
    event SetBuyLimitPrice(uint256 old_price, uint256 new_price);
    event SetBuyLimit(uint256 old_limit, uint256 new_limit);
    event SetUserLimit(address indexed user, uint256 limit);
    event BatchSetUserLimit(address[] users, uint256[] limits);
    event WithdrawFunds(uint256 amount);

    modifier is_owner() {
        require(msg.sender == owner, "You aren't the owner");
        _;
    }

    modifier is_agent() {
        require(msg.sender == agent, "You aren't the agent");
        _;
    }

    constructor(address payable agent_address) {
        require(agent_address != address(0), "Invalid agent address");
        agent = agent_address;
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // Prevent direct value transfers
    receive() external payable {
        revert("Direct value transfers not allowed");
    }

    fallback() external payable {
        revert("Direct value transfers not allowed");
    }

    function transfer_ownership(address new_owner) public is_owner {
        require(new_owner != address(0), "New owner is the zero address");
        pending_owner = new_owner;
        ownership_transfer_timestamp = block.timestamp;
        emit OwnershipTransferInitiated(
            owner,
            new_owner,
            ownership_transfer_timestamp
        );
    }

    function accept_ownership() public {
        require(msg.sender == pending_owner, "Caller is not the pending owner");
        require(
            block.timestamp >= ownership_transfer_timestamp + TIMELOCK_DURATION,
            "Timelock period not elapsed"
        );
        address old_owner = owner;
        owner = pending_owner;
        pending_owner = address(0);
        ownership_transfer_timestamp = 0;
        emit OwnershipTransferred(old_owner, owner);
    }

    function cancel_ownership_transfer() public is_owner {
        require(pending_owner != address(0), "No pending ownership transfer");
        pending_owner = address(0);
        ownership_transfer_timestamp = 0;
    }

    function get_remaining_timelock() public view returns (uint256) {
        if (pending_owner == address(0)) {
            return 0;
        }
        if (
            block.timestamp >= ownership_transfer_timestamp + TIMELOCK_DURATION
        ) {
            return 0;
        }
        return
            (ownership_transfer_timestamp + TIMELOCK_DURATION) -
            block.timestamp;
    }

    function set_buy_limit_price(uint256 limit_price) public is_owner {
        require(limit_price > 0, "Price must be greater than 0");
        buy_limit_price = limit_price;
    }

    function set_buy_limit(uint256 limit) public is_owner {
        require(limit > 0, "Limit must be greater than 0");
        buy_limit = limit;
    }

    function set_user_limit(
        address user_address,
        uint256 limit
    ) public is_owner {
        require(user_address != address(0), "Invalid user address");
        user_chat_limit[user_address] = limit;
        emit SetUserLimit(user_address, limit);
    }

    function batch_set_user_limit(
        address[] memory user_addresses,
        uint256[] memory limits
    ) public is_owner {
        require(
            user_addresses.length == limits.length,
            "Array lengths must match"
        );
        for (uint256 i = 0; i < user_addresses.length; i++) {
            require(user_addresses[i] != address(0), "Invalid user address");
            user_chat_limit[user_addresses[i]] = limits[i];
        }
        emit BatchSetUserLimit(user_addresses, limits);
    }

    function buy_chat_limit() public payable {
        require(msg.value == buy_limit_price, "Balance is not enough");
        // Update state before external call (checks-effects-interactions pattern)
        (bool success, ) = agent.call{value: msg.value}("");
        require(success, "Transfer failed");
        user_chat_limit[msg.sender] += buy_limit;
        emit BuyChatLimit(msg.sender, buy_limit);
    }
}
