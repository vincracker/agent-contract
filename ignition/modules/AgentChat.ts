// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("AgentChat", (m) => {
    // Get the agent address from environment variable
    const agentAddress = process.env.AGENT_ADDRESS;
    if (!agentAddress) {
        throw new Error("AGENT_ADDRESS environment variable is not set");
    }

    // Deploy the AgentChat contract
    const agentChat = m.contract("AgentChat", [agentAddress]);

    return { agentChat };
});
