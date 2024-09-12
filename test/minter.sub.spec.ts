import { it } from "mocha";
import { artifacts, ethers } from "hardhat";
import { parseEther } from "ethers";
import { Address } from "@unique-nft/utils";
import { expect } from "chai";
import testConfig from "./utils/config";
import { Sr25519Account } from "@unique-nft/sdk/sr25519";
import { Sdk } from "@unique-nft/sdk/full";

it("Substrate: Can mint collection for free and mint tokens for free after that", async () => {
  const [minterOwner] = await ethers.getSigners();

  // Generate an empty account
  const user = Sr25519Account.fromUri(Sr25519Account.generateMnemonic());

  const sdk = new Sdk({ baseUrl: testConfig.rest, account: user });

  const balanceMinterOwner = await ethers.provider.getBalance(minterOwner);

  // Owner needs some balance to mint contract
  expect(balanceMinterOwner).to.be.greaterThan(100n * 10n ** 18n);

  // NOTE: get user's balance before minting
  // user will send transactions but for *free*
  const userBalanceBefore = await sdk.balance.get(user);
  console.log(userBalanceBefore.availableBalance.formatted);

  // NOTE: minterOwner deploy Minter contract
  const MinterFactory = await ethers.getContractFactory("Minter");
  const minter = await MinterFactory.connect(minterOwner).deploy({
    gasLimit: 3000_000,
    value: parseEther("100"),
  });
  await minter.waitForDeployment();
  const minterAddress = await minter.getAddress();

  // NOTE: minterOwner sets self-sponsorship for the contract
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
  const minterArtifacts = await artifacts.readArtifact("Minter");

  // We do not not want to provide ABI and contract address every time
  const minterContractSub = await sdk.evm.contractConnect(
    minterAddress,
    minterArtifacts.abi,
  );

  const mintCollectionResult = await minterContractSub.send({
    funcName: "mintCollection",
    args: [
      "N",
      "NN",
      "NNN",
      "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmQRUMbyfvioTcYiJYorEK6vNT3iN4pM6Sci9A2gQBuwuA",
      { token_owner: true, collection_admin: true, restricted: [] },
      // NOTICE: CrossAddress: that is how we set a substrate address as a collection owner:
      {
        eth: ethers.ZeroAddress,
        sub: Address.extract.substratePublicKey(user.address),
      },
    ],
    gasLimit: 1_000_000,
  });

  // NOTE: just print minted collection address
  const filter = minter.filters.CollectionCreated;
  const [event] = await minter.queryFilter(filter, -100);
  console.log(event.args.collectionAddress);

  // NOTE: user mints token for free!
  // fees will be paid by "Minter" contract
  await minterContractSub.send({
    funcName: "mintToken",
    args: [
      event.args.collectionAddress,
      "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmY7hbSNiwE3ApYp83CHWFdqrcEAM6AvChucBVA6kC1e8u",
      [{ trait_type: "Power", value: "42" }],
      // NOTICE: CrossAddress - set a substrate address as a token owner
      {
        eth: ethers.ZeroAddress,
        sub: Address.extract.substratePublicKey(user.address),
      },
    ],
    gasLimit: 1_000_000,
  });

  // NOTE: check that user's balance doesn't change
  const userBalanceAfter = await sdk.balance.get(user);
  expect(userBalanceAfter.availableBalance.raw).to.deep.eq(
    userBalanceBefore.availableBalance.raw,
  );
});
