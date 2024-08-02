import { it } from "mocha";
import { viem } from "hardhat";

it("Can mint collection", async () => {
  const minter = await viem.deployContract("Minter", []);
});
