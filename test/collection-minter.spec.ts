import { it } from "mocha";
import { ethers } from "hardhat";
import { parseEther } from "ethers";
import { Address } from "@unique-nft/utils";
import { expect } from "chai";
import testConfig from "./utils/config";

it("Can mint collection for free and mint tokens for free after that", async () => {
  const [collectionOwner, user] = await ethers.getSigners();

  // NOTE: get user's balance before minting
  // user will send transactions but for *free*
  const userBalanceBefore = await ethers.provider.getBalance(user);
  console.log(userBalanceBefore);

  // NOTE: collectionOwner deploy Minter contract
  const MinterFactory = await ethers.getContractFactory("Minter");
  const minter = await MinterFactory.connect(collectionOwner).deploy({
    gasLimit: 3000_000,
    value: parseEther("30"),
  });
  await minter.waitForDeployment();
  const minterAddress = await minter.getAddress();

  // NOTE: collectionOwner sets self-sponsorship for the contract
  const contractHelpers = testConfig.contractHelpers.connect(collectionOwner);
  await contractHelpers.selfSponsoredEnable(minter);
  // Set rate limit 0 (every tx will be sponsored)
  await contractHelpers.setSponsoringRateLimit(minter, 0);
  // Set generous mode (all users sponsored)
  await contractHelpers.setSponsoringMode(minter, 2);

  // Log Minter's address
  console.log(
    "MINTER",
    minterAddress,
    Address.mirror.ethereumToSubstrate(minterAddress),
  );

  // NOTE: user mints collection for free!
  // This collection will be automatically sponsored by Minter
  const mintCollectionTx = await minter
    .connect(user)
    .mintCollection(
      "N",
      "NN",
      "NNN",
      "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmQRUMbyfvioTcYiJYorEK6vNT3iN4pM6Sci9A2gQBuwuA",
      { gasLimit: 1000_000 },
    );

  const receipt = await mintCollectionTx.wait();
  if (!receipt) throw Error("No receipt");

  // NOTE: just print minted collection address
  const filter = minter.filters.CollectionCreated;
  const [event] = await minter.queryFilter(filter, -100);
  console.log(event.args.collectionAddress);

  // NOTE: user mints token for free!
  // fees will be paid by Minter
  await minter
    .connect(user)
    .mintToken(
      event.args.collectionAddress,
      "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmY7hbSNiwE3ApYp83CHWFdqrcEAM6AvChucBVA6kC1e8u",
      [{ trait_type: "Power", value: "42" }],
      { gasLimit: 300000 },
    );

  // NOTE: check that user's balance doesn't changed
  const userBalanceAfter = await ethers.provider.getBalance(user);
  expect(userBalanceAfter).to.deep.eq(userBalanceBefore);
});
