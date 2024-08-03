import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import testConfig from "./test/utils/config";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    testnet: {
      url: testConfig.rpc,
      accounts: testConfig.accounts,
      chainId: 8882,
    },
  },
  defaultNetwork: "testnet",
  mocha: {
    timeout: 10 * 60 * 1000,
  },
};

export default config;
