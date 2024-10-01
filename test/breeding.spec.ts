import { it } from "mocha";
import { ethers } from "hardhat";
import { parseEther } from "ethers";
import { Address } from "@unique-nft/utils";
import { expect } from "chai";
import testConfig from "./utils/config";

it("EVM: Can mint breeding contract", async () => {
  const [minterOwner] = await ethers.getSigners();

  const Factory = await ethers.getContractFactory("BreedingSimulator", {});
  const breeder = await Factory.connect(minterOwner).deploy({
    gasLimit: 6_000_000,
    value: parseEther("2"),
  });
  await breeder.waitForDeployment();

  const cross = Address.extract.ethCrossAccountId(minterOwner.address);

  const res = await breeder._uintToString(1);

  const nftTx = await breeder.breed(cross, { gasLimit: 3_000_000 });
  await nftTx.wait();
});
