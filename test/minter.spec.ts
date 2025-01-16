import { it } from "mocha";
import { ethers } from "hardhat";
import { parseEther } from "ethers";
import { Address } from "@unique-nft/utils";
import { expect } from "chai";
import testConfig from "./utils/config";

it("EVM: Can mint collection for free and mint tokens for free after that", async () => {
  const [minterOwner] = await ethers.getSigners();

  const user = ethers.Wallet.createRandom(ethers.provider);

  console.log(await ethers.provider.getBalance(minterOwner));

  // NOTE: get user's balance before minting
  // user will send transactions but for *free*
  const userBalanceBefore = await ethers.provider.getBalance(user);
  console.log(userBalanceBefore);

  // NOTE: minterOwner deploy Minter contract
  const MinterFactory = await ethers.getContractFactory("Minter");
  const minter = await MinterFactory.connect(minterOwner).deploy({
    gasLimit: 3500_000,
    value: parseEther("100"),
  });
  await minter.waitForDeployment();
  const minterAddress = await minter.getAddress();

  // // NOTE: minterOwner sets self-sponsorship for the contract
  const contractHelpers = testConfig.contractHelpers.connect(minterOwner);
  await contractHelpers
    .selfSponsoredEnable(minter, { gasLimit: 300_000 })
    .then((tx) => tx.wait());
  // Set rate limit 0 (every tx will be sponsored)
  await contractHelpers
    .setSponsoringRateLimit(minter, 0, {
      gasLimit: 300_000,
    })
    .then((tx) => tx.wait());
  // Set generous mode (all users sponsored)
  await contractHelpers
    .setSponsoringMode(minter, 2, { gasLimit: 300_000 })
    .then((tx) => tx.wait());

  // Log Minter's address
  console.log(
    "MINTER",
    minterAddress,
    Address.mirror.ethereumToSubstrate(minterAddress),
  );

  // NOTE: user mints collection for free!
  // This collection will be automatically sponsored by Minter
  const mintCollectionTx = await minter.connect(user).mintCollection(
    "N",
    "NN",
    "NNN",
    "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmQRUMbyfvioTcYiJYorEK6vNT3iN4pM6Sci9A2gQBuwuA",
    { token_owner: true, collection_admin: true, restricted: [] },
    // CrossAddress: user sets its ethereum address as a collection owner
    { eth: user.address, sub: 0 },
    { gasLimit: 300_000 },
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
      'Token "Name"',
      'This is "the" description',
      [{ trait_type: "Power", value: "42" }],
      // CrossAddress: user sets its own address as a token owner
      { eth: user.address, sub: 0 },
      { gasLimit: 500000 },
    )
    .then((tx) => tx.wait());

  // NOTE: check that user's balance doesn't change
  const userBalanceAfter = await ethers.provider.getBalance(user);
  expect(userBalanceAfter).to.deep.eq(userBalanceBefore);
});
