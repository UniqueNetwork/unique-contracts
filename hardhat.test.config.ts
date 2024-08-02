import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import testConfig from "./test/config";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    hardhat: {},
    opal: {
      url: "https://ws-opal.unique.network",
      accounts: testConfig.accounts,
    },
  },
};

export default config;
