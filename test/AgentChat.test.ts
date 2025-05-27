import { expect } from "chai";
import { ethers } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import { AgentChat } from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("AgentChat", function () {
    let agentChat: AgentChat;
    let owner: SignerWithAddress;
    let agent: SignerWithAddress;
    let user1: SignerWithAddress;
    let user2: SignerWithAddress;
    const DEFAULT_BUY_LIMIT = 100;
    const DEFAULT_PRICE = ethers.parseEther("0.000000000000000001"); // 1 wei

    beforeEach(async function () {
        [owner, agent, user1, user2] = await ethers.getSigners();

        const AgentChat = await ethers.getContractFactory("AgentChat");
        agentChat = await AgentChat.deploy(agent.address);
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await agentChat.owner()).to.equal(owner.address);
        });

        it("Should set the right agent", async function () {
            expect(await agentChat.agent()).to.equal(agent.address);
        });

        it("Should set the default buy limit", async function () {
            expect(await agentChat.buy_limit()).to.equal(DEFAULT_BUY_LIMIT);
        });

        it("Should set the default price", async function () {
            expect(await agentChat.buy_limit_price()).to.equal(DEFAULT_PRICE);
        });
    });

    describe("Ownership Transfer", function () {
        it("Should allow owner to initiate transfer", async function () {
            await agentChat.transfer_ownership(user1.address);
            expect(await agentChat.pending_owner()).to.equal(user1.address);
        });

        it("Should not allow non-owner to initiate transfer", async function () {
            await expect(
                agentChat.connect(user1).transfer_ownership(user2.address)
            ).to.be.revertedWith("You aren't the owner");
        });

        it("Should not allow transfer to zero address", async function () {
            await expect(
                agentChat.transfer_ownership(ethers.ZeroAddress)
            ).to.be.revertedWith("New owner is the zero address");
        });

        it("Should enforce timelock period", async function () {
            await agentChat.transfer_ownership(user1.address);
            await expect(
                agentChat.connect(user1).accept_ownership()
            ).to.be.revertedWith("Timelock period not elapsed");
        });

        it("Should allow ownership transfer after timelock", async function () {
            await agentChat.transfer_ownership(user1.address);
            await time.increase(24 * 60 * 60 + 1); // 1 day + 1 second
            await agentChat.connect(user1).accept_ownership();
            expect(await agentChat.owner()).to.equal(user1.address);
        });

        it("Should allow owner to cancel transfer", async function () {
            await agentChat.transfer_ownership(user1.address);
            await agentChat.cancel_ownership_transfer();
            expect(await agentChat.pending_owner()).to.equal(ethers.ZeroAddress);
        });
    });

    describe("Buy Chat Limit", function () {
        it("Should allow user to buy chat limit", async function () {
            const initialBalance = await ethers.provider.getBalance(agent.address);
            await agentChat.connect(user1).buy_chat_limit({ value: DEFAULT_PRICE });

            expect(await agentChat.user_chat_limit(user1.address)).to.equal(DEFAULT_BUY_LIMIT);
            expect(await ethers.provider.getBalance(agent.address)).to.equal(
                initialBalance + DEFAULT_PRICE
            );
        });

        it("Should revert if incorrect amount sent", async function () {
            await expect(
                agentChat.connect(user1).buy_chat_limit({ value: DEFAULT_PRICE + 1n })
            ).to.be.revertedWith("Balance is not enough");
        });
    });

    describe("Admin Functions", function () {
        it("Should allow owner to set buy limit price", async function () {
            const newPrice = ethers.parseEther("0.1");
            await agentChat.set_buy_limit_price(newPrice);
            expect(await agentChat.buy_limit_price()).to.equal(newPrice);
        });

        it("Should allow owner to set buy limit", async function () {
            const newLimit = 200;
            await agentChat.set_buy_limit(newLimit);
            expect(await agentChat.buy_limit()).to.equal(newLimit);
        });

        it("Should not allow non-owner to set buy limit price", async function () {
            await expect(
                agentChat.connect(user1).set_buy_limit_price(ethers.parseEther("0.1"))
            ).to.be.revertedWith("You aren't the owner");
        });

        it("Should allow owner to set user limit", async function () {
            const limit = 50;
            await agentChat.set_user_limit(user1.address, limit);
            expect(await agentChat.user_chat_limit(user1.address)).to.equal(limit);
        });

        it("Should allow owner to batch set user limits", async function () {
            const users = [user1.address, user2.address];
            const limits = [30, 40];
            await agentChat.batch_set_user_limit(users, limits);

            expect(await agentChat.user_chat_limit(user1.address)).to.equal(30);
            expect(await agentChat.user_chat_limit(user2.address)).to.equal(40);
        });

        it("Should revert batch set if array lengths don't match", async function () {
            const users = [user1.address, user2.address];
            const limits = [30];
            await expect(
                agentChat.batch_set_user_limit(users, limits)
            ).to.be.revertedWith("Array lengths must match");
        });
    });

}); 