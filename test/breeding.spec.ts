import { it } from "mocha";
import { ethers } from "hardhat";
import { parseEther } from "ethers";
import { Address } from "@unique-nft/utils";

it("EVM: Can mint breeding contract", async () => {
  const [owner1, owner2] = await ethers.getSigners();

  const Factory = await ethers.getContractFactory("BreedingGame", {});
  const breeder = await Factory.connect(owner1).deploy({
    gasLimit: 6_000_000,
    value: parseEther("2"),
  });
  await breeder.waitForDeployment();

  const crossOwner1 = Address.extract.ethCrossAccountId(owner1.address);
  const crossOwner2 = Address.extract.ethCrossAccountId(owner2.address);

  await breeder
    .connect(owner1)
    .breed(crossOwner1, { gasLimit: 3_000_000 })
    .then((tx) => tx.wait());

  await breeder
    .connect(owner2)
    .breed(crossOwner2, { gasLimit: 3_000_000 })
    .then((tx) => tx.wait());

  await breeder.connect(owner1).enterArena(1, { gasLimit: 1000_000 });
  await breeder.connect(owner2).enterArena(2, { gasLimit: 1000_000 });
});
