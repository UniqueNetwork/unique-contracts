// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueNFTMetadata} from "../libraries/UniqueNFTMetadata.sol";
import {UniqueNFT} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
import {UniqueV2CollectionMinter} from "../UniqueV2CollectionMinter.sol";
import {UniqueV2TokenMinter, Attribute, CrossAddress} from "../UniqueV2TokenMinter.sol";

struct TokenStats {
    uint32 breed;
    uint32 generation;
    uint64 victories;
    uint64 defeats;
    uint64 experience;
}

contract BreedingSimulator is UniqueV2CollectionMinter, UniqueV2TokenMinter {
    using UniqueNFTMetadata for address;

    uint32 constant BREEDS = 2;
    address private immutable COLLECTION_ADDRESS;

    mapping(uint256 generation => string ipfs) private s_generationIpfs;
    mapping(uint256 tokenId => TokenStats) private s_tokenStats;

    ///@dev This contract mints fighting collection in the constructor.
    ///     UniqueV2CollectionMinter(true, true, false) means token attributes will be:
    ///     mutable (true) by the collection admin (true), but not by the token owner (false)
    constructor() payable UniqueV2CollectionMinter(true, true, false) {
        s_generationIpfs[
            0
        ] = "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmedQFp656axCAvKjo1iXqozH4Ew7AvDx8SFM4sH3hYHj6/";
        s_generationIpfs[
            1
        ] = "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmPqsyQRozG1vs2ZpgbPWQDbySqibaG6Q3sV7PGmSCxrBH/";
        COLLECTION_ADDRESS = _mintCollection(
            "Evolved",
            "Breeding simulator",
            "EVLD",
            "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmQgGuP4LFST3tMF46vQKow1Ki6oe47GKan1GDjD7z2JPD"
        );
    }

    receive() external payable {}

    function breed(CrossAddress memory _owner) external {
        // we have only 2 predefined images, type 1 or type 2
        uint32 randomTokenBreed = _getPseudoRandom(BREEDS, 1);

        // Construct token image url
        string memory randomImage = string.concat(s_generationIpfs[0], "monster-", _uint2str(randomTokenBreed), ".png");

        Attribute[] memory attributes = new Attribute[](3);

        attributes[0] = Attribute({trait_type: "Experience", value: "0"});
        attributes[1] = Attribute({trait_type: "Victories", value: "0"});
        attributes[2] = Attribute({trait_type: "Defeats", value: "0"});

        uint256 tokenId = _createToken(COLLECTION_ADDRESS, randomImage, attributes, _owner);
        s_tokenStats[tokenId] = TokenStats({
            breed: randomTokenBreed,
            generation: 0,
            victories: 0,
            defeats: 0,
            experience: 0
        });
    }

    // TODO make private
    function fight(uint256 _tokenId1, uint256 _tokenId2) external {
        uint256 winner = _getPseudoRandom(2, 0);
        if (winner == 0) {
            // tokenId1 wins
            _increment(_tokenId1, "Experience", 50);
            _increment(_tokenId1, "Victories", 1);
            _increment(_tokenId2, "Defeats", 1);
            _increment(_tokenId2, "Experience", 10);
            _makeExhausted(_tokenId2);
        } else {
            // tokenId2 wins
            _increment(_tokenId2, "Experience", 50);
            _increment(_tokenId2, "Victories", 1);
            _increment(_tokenId1, "Defeats", 1);
            _increment(_tokenId1, "Experience", 10);
            _makeExhausted(_tokenId1);
        }
    }

    /**
     * @dev Function to mint a new collection.
     * @param _name Name of the collection.
     * @param _description Description of the collection.
     * @param _symbol Symbol prefix for the tokens in the collection.
     * @param _collectionCover URL of the cover image for the collection.
     * @return Address of the created collection.
     */
    function _mintCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover
    ) private returns (address) {
        // TODO make private
        address collectionAddress = _createCollection(_name, _description, _symbol, _collectionCover);

        UniqueNFT collection = UniqueNFT(collectionAddress);

        // Set and confirm collection sponsorship by the contract address
        collection.setCollectionSponsorCross(CrossAddress({eth: address(this), sub: 0}));
        collection.confirmCollectionSponsorship();
        // TODO: Sponsor every transaction

        // Set this contract as an admin
        // Because the minted collection will be owned by the user this contract
        // has to be set as a collection admin in order to be able to mint NFTs
        collection.addCollectionAdminCross(CrossAddress({eth: address(this), sub: 0}));

        return collectionAddress;
    }

    function _increment(uint256 _tokenId, string memory _trait, uint256 _value) private {
        bytes memory traitValueBytes = COLLECTION_ADDRESS.getTraitValue(_tokenId, bytes(_trait));
        uint256 currentValue = 0;
        if (traitValueBytes.length > 0) {
            string memory traitValueStr = string(traitValueBytes);
            currentValue = _str2uint(traitValueStr);
        }
        uint256 newValue = currentValue + _value;
        string memory newValueStr = _uint2str(newValue);
        COLLECTION_ADDRESS.setTrait(_tokenId, bytes(_trait), bytes(newValueStr));
    }

    function _str2uint(string memory _a) private pure returns (uint256) {
        bytes memory bresult = bytes(_a);
        uint256 result = 0;
        for (uint256 i = 0; i < bresult.length; i++) {
            uint8 digit = uint8(bresult[i]) - 48;
            require(digit <= 9, "Invalid character in string");
            result = result * 10 + digit;
        }
        return result;
    }

    function _uint2str(uint256 _i) private pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 temp = _i;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_i != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_i % 10)));
            _i /= 10;
        }
        return string(buffer);
    }

    function _makeExhausted(uint256 _tokenId) private {
        TokenStats memory tokenStats = s_tokenStats[_tokenId];
        string memory exhaustedImage = string.concat(
            s_generationIpfs[tokenStats.generation],
            "monster-",
            _uint2str(tokenStats.breed),
            "b.png"
        );

        COLLECTION_ADDRESS.setImage(_tokenId, bytes(exhaustedImage));
    }

    function _getPseudoRandom(uint256 _modulo, uint256 startFrom) private view returns (uint32) {
        uint256 randomHash = uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)));

        return uint32((randomHash % _modulo) + startFrom);
    }
}
