import { it } from "mocha";
import { ethers } from "hardhat";
import { expect } from "chai";
import { UniqueNFTFactory } from '@unique-nft/solidity-interfaces';
import { parseUnits } from "ethers";

const COLLECTION_ID = 874;
const MARKET_CONTRACT = '0xa91f3d0bd99d78d39d36f553895fe51374e837e3';

it("uses deployed BatchTokenSale for batch sale with approvals", async () => {
    const [owner] = await ethers.getSigners();

    const BatchTokenSaleFactory = await ethers.getContractFactory("BatchTokenSaleWithApproval");
    const batchSaleContract = await BatchTokenSaleFactory.connect(owner).deploy({ gasLimit: 3_500_000 });
    await batchSaleContract.waitForDeployment();

    const batchSaleContractAddress = await batchSaleContract.getAddress();
    console.log("BatchTokenSale contract address:", batchSaleContractAddress);

    const sales = [
        { collectionId: COLLECTION_ID, tokenId: 10, price: parseUnits((1).toString(), 18), currency: 0 },
        { collectionId: COLLECTION_ID, tokenId: 11, price: parseUnits((1).toString(), 18), currency: 0 }
    ];

    const signer = await owner.provider.getSigner();

    //@ts-ignore
    const nftFactory = await UniqueNFTFactory(COLLECTION_ID, signer);

    const result = await nftFactory.setApprovalForAll(MARKET_CONTRACT, true, { gasLimit: 500_000 });
    console.log("Approve transaction receipt:", result)

    const sellTx = await batchSaleContract.connect(owner).batchSell(
        MARKET_CONTRACT,
        sales,
        owner.address,
        { gasLimit: 3_500_000 }
    );
    const sellReceipt = await sellTx.wait();
    if (!sellReceipt) throw Error("No receipt from sell");

    console.log("Sell transaction receipt:", sellReceipt);
});
