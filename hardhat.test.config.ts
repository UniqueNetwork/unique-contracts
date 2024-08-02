import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import testConfig from "./test/config";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    hardhat: {},
    opal: {
      url: "https://ws-opal.unique.network",
      accounts: testConfig.accounts,
      chainId: 8882,
    },
  },
  mocha: {
    timeout: 10 * 60 * 1000,
  },
};

export default config;
