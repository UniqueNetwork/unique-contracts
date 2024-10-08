import * as dotenv from "dotenv";
import {
  ContractHelpers__factory,
  CollectionHelpers__factory,
} from "../../typechain-types";
dotenv.config();

const getConfig = () => {
  const { TEST_ACCOUNTS_ETH, TEST_NETWORK, TEST_REST } = process.env;
  if (!TEST_ACCOUNTS_ETH || !TEST_NETWORK || !TEST_REST)
    throw Error("Did you forget to set .env");

  const contractHelpers = ContractHelpers__factory.connect(
    "0x842899ecf380553e8a4de75bf534cdf6fbf64049",
  );

  const collectionHelpers = CollectionHelpers__factory.connect(
    "0x6C4E9fE1AE37a41E93CEE429e8E1881aBdcbb54F",
  );

  const accounts = TEST_ACCOUNTS_ETH.split(",");

  return {
    accounts,
    rpc: TEST_NETWORK,
    rest: TEST_REST,
    contractHelpers,
    collectionHelpers,
  };
};

export default getConfig();
