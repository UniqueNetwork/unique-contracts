import * as dotenv from "dotenv";
dotenv.config();

const getConfig = () => {
  const { TEST_ACCOUNTS_ETH } = process.env;
  if (!TEST_ACCOUNTS_ETH) throw Error("Did you forget to set .env");

  const accounts = TEST_ACCOUNTS_ETH.split(",");

  return {
    accounts,
  };
};

export default getConfig();
