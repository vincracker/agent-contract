// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const AGENT_ADDRESS = "0x0000000000000000000000000000000000000000";
// const LIMIT_PRICE = 1e14;
// const LIMIT = 100;

const AgentChatModule = buildModule("AgentChatModule", (m) => {
    const agentAddress = m.getParameter("agentAddress", AGENT_ADDRESS);

    const agentChat = m.contract("AgentChat", [agentAddress]);

    return { agentChat };
});

export default AgentChatModule;
