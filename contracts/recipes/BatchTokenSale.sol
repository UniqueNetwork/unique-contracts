// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniqueNFTFactory {
    function approve(address approved, uint256 tokenId) external;
}

interface IMarketContract {
    function put(
        uint256 collectionId,
        uint256 tokenId,
        uint256 price,
        uint256 currency,
        uint256 amount,
        address from
    ) external payable;
}

contract BatchTokenSaleWithApproval {
    struct TokenSale {
        uint256 collectionId;
        uint256 tokenId;
        uint256 price;
    }

    function batchSell(
        address marketContractAddress,
        TokenSale[] calldata sales,
        address from
    ) external payable {
        IMarketContract marketContract = IMarketContract(marketContractAddress);

        for (uint256 i = 0; i < sales.length; i++) {
            TokenSale memory sale = sales[i];
            marketContract.put(
                sale.collectionId,
                sale.tokenId,
                sale.price,
                0,
                1, // Fixed amount
                from
            );
        }
    }
}
