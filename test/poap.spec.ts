import { it } from "mocha";
import { ethers } from "hardhat";
import { expect } from "chai";
import testConfig from "./utils/config";

it("POAP contract owner can create event and user without UNQ can mint NFT", async () => {
  const [collectionOwner, eventHost] = await ethers.getSigners();
  const userWithoutUNQ = ethers.Wallet.createRandom().connect(ethers.provider);

  // NOTE: everyone who wants to create event should pay 5 UNQ
  const EVENT_CREATION_FEE = 5n * 10n ** 18n;
  const POAP_BALANCE = 30n * 10n ** 18n;

  // NOTE: expect user has no UNQ tokens
  // user will send transactions but for *free*
  const userBalanceBefore = await ethers.provider.getBalance(userWithoutUNQ);
  expect(userBalanceBefore).to.deep.eq(0n);

  // NOTE: collectionOwner deploy POAP contract
  const PoapFactory = await ethers.getContractFactory("POAP");
  const poap = await PoapFactory.connect(collectionOwner).deploy(
    EVENT_CREATION_FEE,
    { gasLimit: 3000_000, value: POAP_BALANCE },
  );
  await poap.waitForDeployment();
  const poapAddress = await poap.getAddress();

  // NOTE: collectionOwner sets self-sponsorship for the contract
  // All transactions fee will be paid by POAP contract itself
  const contractHelpers = testConfig.contractHelpers.connect(collectionOwner);
  await contractHelpers.selfSponsoredEnable(poap, { gasLimit: 300_000 });
  // ...set rate limit 0 (every tx will be sponsored)
  await contractHelpers.setSponsoringRateLimit(poap, 0, {
    gasLimit: 300_000,
  });
  // ...set generous mode (all users sponsored)
  await contractHelpers.setSponsoringMode(poap, 2, { gasLimit: 300_000 });

  // Log POAP's address
  console.log("POAP", poapAddress);

  // NOTE: get current timestamp
  const timestampNow = await poap.timestampNow();
  const eventStartTime = timestampNow + 50n;
  const eventEndTime = timestampNow + 200n;

  // NOTE: event-host mints collection for 5 UNQ (EVENT_CREATION_FEE)
  // This collection will be automatically sponsored by POAP contract
  const eventHostBalanceBefore = await ethers.provider.getBalance(eventHost);
  const mintCollectionTx = await poap.connect(eventHost).createCollection(
    "N",
    "NN",
    "NNN",
    "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmQRUMbyfvioTcYiJYorEK6vNT3iN4pM6Sci9A2gQBuwuA",
    {
      startTimestamp: eventStartTime,
      endTimestamp: eventEndTime,
      tokenImage:
        "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmQRUMbyfvioTcYiJYorEK6vNT3iN4pM6Sci9A2gQBuwuA",
      attributes: [
        { trait_type: "Power", value: "10" },
        { trait_type: "Description", value: "Mem token" },
      ],
    },
    { gasLimit: 2000_000, value: EVENT_CREATION_FEE },
  );

  const receipt = await mintCollectionTx.wait();
  if (!receipt) throw Error("No receipt");

  // eventHost's balance reduced for 5 UNQ
  const eventHostBalanceAfter = await ethers.provider.getBalance(eventHost);
  expect(eventHostBalanceAfter).to.deep.eq(
    eventHostBalanceBefore - EVENT_CREATION_FEE,
  );

  // NOTE: just print minted collection address
  const filter = poap.filters.CollectionCreated;
  const [event] = await poap.queryFilter(filter, -100);
  console.log("Collection address", event.args.collectionAddress);

  // NOTE: userWithoutUNQ do not have any UNQ and mints token for free!
  // fees will be paid by POAP contract
  await poap
    .connect(userWithoutUNQ)
    .createToken(
      event.args.collectionAddress,
      { eth: userWithoutUNQ.address, sub: 0 },
      { gasLimit: 300_000 },
    )
    .then((tx) => tx.wait());

  console.log("POAP balance after:", await ethers.provider.getBalance(poap));
});
