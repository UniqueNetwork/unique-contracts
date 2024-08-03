import * as dotenv from "dotenv";
import { ContractHelpers__factory } from "../../typechain-types";
dotenv.config();

const getConfig = () => {
  const { TEST_ACCOUNTS_ETH, TEST_NETWORK } = process.env;
  if (!TEST_ACCOUNTS_ETH || !TEST_NETWORK)
    throw Error("Did you forget to set .env");

  const contractHelpers = ContractHelpers__factory.connect(
    "0x842899ecf380553e8a4de75bf534cdf6fbf64049",
  );

  const accounts = TEST_ACCOUNTS_ETH.split(",");

  return {
    accounts,
    rpc: TEST_NETWORK,
    contractHelpers,
  };
};

export default getConfig();
