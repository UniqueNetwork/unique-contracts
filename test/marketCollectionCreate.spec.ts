import { it } from "mocha";
import { ethers } from "hardhat";
import { expect } from "chai";
import testConfig from "./utils/config";

it("should deploy and create collection in MarketCollectionCreate contract", async () => {
  const [collectionOwner] = await ethers.getSigners();
  const contractHelpers = testConfig.collectionHelpers.connect(collectionOwner);
  const MarketCollectionFactory = await ethers.getContractFactory(
    "MarketCollectionCreate",
  );
  const marketCollectionCreate = await MarketCollectionFactory.connect(
    collectionOwner,
  ).deploy({ gasLimit: 3_500_000 });
  await marketCollectionCreate.waitForDeployment();
  const marketCollectionAddress = await marketCollectionCreate.getAddress();

  console.log(
    "MarketCollectionCreate contract address:",
    marketCollectionAddress,
  );

  expect(marketCollectionAddress).to.be.properAddress;

  const mintCollectionTx = await marketCollectionCreate
    .connect(collectionOwner)
    .createCollection(
      "Test Collection",
      "TC",
      "TCC",
      "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmQRUMbyfvioTcYiJYorEK6vNT3iN4pM6Sci9A2gQBuwuA",
      true,
      1000,
      50,
      true,
      true,
      {
        gasLimit: 2000_000,
        value: await contractHelpers.collectionCreationFee(),
      },
    );

  const receipt = await mintCollectionTx.wait();
  if (!receipt) throw Error("No receipt");

  const filter = marketCollectionCreate.filters.CollectionCreated;
  const [event] = await marketCollectionCreate.queryFilter(filter, -100);
  console.log("Created collection address:", event.args.collectionAddress);

  expect(event.args.collectionAddress).to.be.properAddress;
});
