// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueNFTMetadata} from "../libraries/UniqueNFTMetadata.sol";
import {Converter} from "../libraries/utils/Converter.sol";
import {UniqueV2CollectionMinter} from "../UniqueV2CollectionMinter.sol";
import {UniqueV2TokenMinter, Attribute} from "../UniqueV2TokenMinter.sol";
import {AddressUtils, CrossAddress} from "../libraries/utils/AddressUtils.sol";

struct TokenStats {
    uint32 breed;
    uint32 generation;
    uint64 victories;
    uint64 defeats;
    uint64 experience;
}

contract BreedingSimulator is UniqueV2CollectionMinter, UniqueV2TokenMinter {
    using UniqueNFTMetadata for address;
    using AddressUtils for *;
    using Converter for *;

    uint32 constant BREEDS = 2;
    uint256 constant EVOLUTION_EXPERIENCE = 150;
    address private immutable COLLECTION_ADDRESS;

    mapping(uint256 generation => string ipfs) private s_generationIpfs;
    mapping(uint256 tokenId => TokenStats) private s_tokenStats;
    uint256 private s_gladiator;

    modifier onlyTokenOwner(uint256 _tokenId) {
        require(
            AddressUtils.messageSenderIsTokenOwner(COLLECTION_ADDRESS, _tokenId),
            "BreedingSimulator: msg.sender is not the owner"
        );
        _;
    }

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
        string memory randomImage = string.concat(
            s_generationIpfs[0],
            "monster-",
            Converter.uint2str(randomTokenBreed),
            ".png"
        );

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

    function evolve(uint256 _tokenId) external onlyTokenOwner(_tokenId) {
        TokenStats memory tokenStats = s_tokenStats[_tokenId];
        require(tokenStats.experience >= EVOLUTION_EXPERIENCE, "Experience not enough");
        require(tokenStats.generation == 0, "Already evolved");

        s_tokenStats[_tokenId].generation += 1;
        _setImage(_tokenId, false);
    }

    function enterArena(uint256 _tokenId) external onlyTokenOwner(_tokenId) {
        if (s_gladiator != 0 && s_gladiator != _tokenId) _fight(s_gladiator, _tokenId);
        else s_gladiator = _tokenId;
    }

    function recover(uint256 _tokenId) external onlyTokenOwner(_tokenId) {
        // TODO: add some extra logic, for example check if a cooldown period has ended
        _setImage(_tokenId, false);
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
        address collectionAddress = _createCollection(_name, _description, _symbol, _collectionCover);

        // You may also set sponsorship fpr the collection to create a fee-less experience:
        // import {UniqueNFT} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
        // UniqueNFT collection = UniqueNFT(collectionAddress);
        // collection.setCollectionSponsorCross(CrossAddress({eth: address(this), sub: 0}));
        // collection.confirmCollectionSponsorship();

        return collectionAddress;
    }

    function _fight(uint256 _tokenId1, uint256 _tokenId2) private {
        (uint256 winner, uint256 loser) = _getPseudoRandom(2, 0) == 0 ? (_tokenId1, _tokenId2) : (_tokenId2, _tokenId1);

        // Update winner's stats
        TokenStats memory winnerStats = s_tokenStats[winner];
        winnerStats.victories += 1;
        winnerStats.experience += 50;
        s_tokenStats[winner] = winnerStats;

        // Update loser's stats
        TokenStats memory loserStats = s_tokenStats[loser];
        loserStats.defeats += 1;
        loserStats.experience += 10;
        s_tokenStats[loser] = loserStats;

        // Change winner's token attributes
        COLLECTION_ADDRESS.setTrait(winner, "Experience", Converter.uint2bytes(winnerStats.experience));
        COLLECTION_ADDRESS.setTrait(winner, "Victories", Converter.uint2bytes(winnerStats.victories));

        // Change loser's token attributes
        COLLECTION_ADDRESS.setTrait(loser, "Experience", Converter.uint2bytes(loserStats.experience));
        COLLECTION_ADDRESS.setTrait(loser, "Defeats", Converter.uint2bytes(loserStats.defeats));
        _makeExhausted(loser);
        delete s_gladiator;
    }

    function _makeExhausted(uint256 _tokenId) private {
        _setImage(_tokenId, true);
        // TODO: we can set a cooldown period to recover the token
    }

    function _setImage(uint256 _tokenId, bool _exhausted) private {
        TokenStats memory tokenStats = s_tokenStats[_tokenId];
        string memory extension = _exhausted ? "b.png" : ".png";
        string memory imageUrl = string.concat(
            s_generationIpfs[tokenStats.generation],
            "monster-",
            Converter.uint2str(tokenStats.breed),
            extension
        );

        COLLECTION_ADDRESS.setImage(_tokenId, bytes(imageUrl));
    }

    function _getPseudoRandom(uint256 _modulo, uint256 startFrom) private view returns (uint32) {
        uint256 randomHash = uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)));

        return uint32((randomHash % _modulo) + startFrom);
    }
}
