import { it } from "mocha";
import { ethers } from "hardhat";
import { parseEther } from "ethers";
import { expect } from "chai";
import { Minter__factory } from "../typechain-types";

it("Can mint collection", async () => {
  const [signer1, signer2] = await ethers.getSigners();

  const signer1Balance = await ethers.provider.getBalance(signer1);

  console.log(
    `Balance of ${signer1.address}: ${ethers.formatEther(signer1Balance)} ETH`,
  );

  const MinterFactory = await ethers.getContractFactory("Minter");
  const minter = await MinterFactory.deploy({
    gasLimit: 3000_000,
    value: parseEther("2"),
  });

  await minter.waitForDeployment();

  const collectionResponse = await minter.mintCollection(
    "N",
    "NN",
    "NNN",
    "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmQRUMbyfvioTcYiJYorEK6vNT3iN4pM6Sci9A2gQBuwuA",
    { gasLimit: 1000_000 },
  );

  const receipt = await collectionResponse.wait();
  if (!receipt) throw Error("No receipt");

  const logs = receipt.logs;
  console.log(receipt.logs);
});
