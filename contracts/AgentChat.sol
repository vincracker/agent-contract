// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract AgentChat {
    address payable public agent;
    address public owner;
    address public pendingOwner;
    uint256 public buy_limit_price = 0.1 ether; // reduced default price for testing
    uint256 public buy_limit = 100; // default limit
    uint256 public totalFunds; // Track total funds in contract

    // user chat limit mapping
    mapping(address => uint256) public user_chat_limit;

    event OwnershipTransferInitiated(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event BuyChatLimit(address indexed user, uint256 amount);
    event SetBuyLimitPrice(uint256 old_price, uint256 new_price);
    event SetBuyLimit(uint256 old_limit, uint256 new_limit);
    event SetUserLimit(address indexed user, uint256 limit);
    event BatchSetUserLimit(address[] users, uint256[] limits);
    event WithdrawFunds(address indexed to, uint256 amount);

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

    function transferOwnership(address newOwner) public is_owner {
        require(newOwner != address(0), "New owner is the zero address");
        pendingOwner = newOwner;
        emit OwnershipTransferInitiated(owner, newOwner);
    }

    function acceptOwnership() public {
        require(msg.sender == pendingOwner, "Caller is not the pending owner");
        address oldOwner = owner;
        owner = pendingOwner;
        pendingOwner = address(0);
        emit OwnershipTransferred(oldOwner, owner);
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
        user_chat_limit[msg.sender] += buy_limit;
        totalFunds += msg.value;
        emit BuyChatLimit(msg.sender, buy_limit);
    }

    function withdrawFunds(uint256 amount) public is_agent {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= totalFunds, "Insufficient funds");
        require(
            amount <= address(this).balance,
            "Insufficient contract balance"
        );

        totalFunds -= amount;
        (bool success, ) = agent.call{value: amount}("");
        require(success, "Transfer failed");
        emit WithdrawFunds(agent, amount);
    }

    function withdrawAllFunds() public is_agent {
        uint256 amount = totalFunds;
        require(amount > 0, "No funds to withdraw");
        totalFunds = 0;
        (bool success, ) = agent.call{value: amount}("");
        require(success, "Transfer failed");
        emit WithdrawFunds(agent, amount);
    }

    // View function to check contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
