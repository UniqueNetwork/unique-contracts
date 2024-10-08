// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueNFTMetadata} from "../libraries/UniqueNFTMetadata.sol";
import {Converter} from "../libraries/utils/Converter.sol";
import {CollectionMinter} from "../CollectionMinter.sol";
import {TokenMinter, Attribute} from "../TokenMinter.sol";
import {AddressUtils, CrossAddress} from "../libraries/utils/AddressUtils.sol";

/// @notice TokenStats represents an NFT's attributes and lifecycle.
struct TokenStats {
    uint32 breed; // The id of an NFT's type. Every breed has a different image.
    uint32 generation; // Every NFT starts with generation 0 and can evolve with experience growth.
    uint64 victories; // Number of victories.
    uint64 defeats; // Number of defeats.
    uint64 experience; // Experience earned.
}

/// @title Breeding Simulator
/// @dev A contract that simulates breeding, evolving, and battling of NFTs.
///      This contract aims to demonstrate how to mutate tokens' images and traits.
///      Users can `breed` new monsters and evolve them with experience growth.
///      You can see the example usage:
///      - For Ethereum accounts: use your Ethereum address in the CrossAddress structure when calling `breed`.
///      - For Substrate accounts: use your Substrate address in the CrossAddress structure when calling `breed`.
contract BreedingGame is CollectionMinter, TokenMinter {
    /// @dev This library allows setting NFT's images and traits.
    using UniqueNFTMetadata for address;
    /// @dev This library provides data type conversion utilities.
    using Converter for *;

    /// @dev Total number of breeds available. For simplicity, only 2 types of tokens (different images) are available.
    uint32 constant BREEDS = 2;

    /// @dev Experience required to evolve to the next generation and change NFT's image.
    uint256 constant EVOLUTION_EXPERIENCE = 150;

    /// @dev Address of the NFT collection. Created at the deploy time.
    address private immutable COLLECTION_ADDRESS;

    /// @dev Mapping from generation to IPFS base URL for images.
    mapping(uint256 generation => string ipfs) private s_generationIpfs;

    /// @dev Mapping from token ID to its stats.
    mapping(uint256 tokenId => TokenStats) private s_tokenStats;

    /// @dev Token ID awaiting for an opponent.
    uint256 private s_gladiator;

    /// @dev Checks if the msg.sender is the owner of the NFT.
    modifier onlyTokenOwner(uint256 _tokenId) {
        require(
            AddressUtils.messageSenderIsTokenOwner(COLLECTION_ADDRESS, _tokenId),
            "BreedingGame: msg.sender is not the owner"
        );
        _;
    }

    /// @dev This contract mints a fighting collection in the constructor.
    ///      CollectionMinter(true, true, false) means token attributes will be:
    ///      mutable (true) by the collection admin (true), but not by the token owner (false).
    constructor() payable CollectionMinter(true, true, false) {
        // Monsters can be of generation 0 or 1. Each generation has its own IPFS base URL.
        s_generationIpfs[
            0
        ] = "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmedQFp656axCAvKjo1iXqozH4Ew7AvDx8SFM4sH3hYHj6/";
        s_generationIpfs[
            1
        ] = "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmPqsyQRozG1vs2ZpgbPWQDbySqibaG6Q3sV7PGmSCxrBH/";

        // The contract mints a collection and becomes the collection owner,
        // so it has permissions to mutate its tokens' attributes.
        COLLECTION_ADDRESS = _mintCollection(
            "Evolved",
            "Breeding simulator",
            "EVLD",
            "https://orange-impressed-bonobo-853.mypinata.cloud/ipfs/QmQgGuP4LFST3tMF46vQKow1Ki6oe47GKan1GDjD7z2JPD"
        );
    }

    receive() external payable {}

    /**
     * @notice Breeds a new token for the given owner.
     * @param _owner CrossAddress representing the owner of the new token.
     */
    function breed(CrossAddress memory _owner) external {
        // For simplicity, we have only 2 predefined images, type 1 or type 2.
        // Each player receives a pseudo-random token breed.
        uint32 randomTokenBreed = _getPseudoRandom(BREEDS, 1);

        // Construct token image URL.
        string memory randomImage = string.concat(
            s_generationIpfs[0],
            "monster-",
            Converter.uint2str(randomTokenBreed),
            ".png"
        );

        Attribute[] memory attributes = new Attribute[](3);
        // Each NFT has 3 traits. These traits are mutated when the `_fight` method is invoked.
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

    /**
     * @notice Evolves the token to the next generation if it has enough experience.
     *         The token's image changes upon evolution.
     * @param _tokenId The ID of the token to evolve.
     */
    function evolve(uint256 _tokenId) external onlyTokenOwner(_tokenId) {
        TokenStats memory tokenStats = s_tokenStats[_tokenId];
        require(tokenStats.experience >= EVOLUTION_EXPERIENCE, "Experience not enough");
        require(tokenStats.generation == 0, "Already evolved");

        s_tokenStats[_tokenId].generation += 1;
        _setImage(_tokenId, false);
    }

    /**
     * @notice Enters the token into the arena for battle.
     *         As a result of a battle, the token's traits and image will change.
     * @param _tokenId The ID of the token to enter the arena.
     */
    function enterArena(uint256 _tokenId) external onlyTokenOwner(_tokenId) {
        if (s_gladiator != 0 && s_gladiator != _tokenId) _fight(s_gladiator, _tokenId);
        else s_gladiator = _tokenId;
    }

    /**
     * @notice Recovers the token after being exhausted from battle.
     *         Changes the token's image to the normal state.
     *         Note: Currently, there is no cooldown period, but this can be extended to include one.
     * @param _tokenId The ID of the token to recover.
     */
    function recover(uint256 _tokenId) external onlyTokenOwner(_tokenId) {
        _setImage(_tokenId, false);
    }

    function getGladiator() external view returns (uint256) {
        return s_gladiator;
    }

    function canEvolve(uint256 _tokenId) external view returns (bool) {
        TokenStats memory tokenStats = s_tokenStats[_tokenId];
        return tokenStats.experience >= EVOLUTION_EXPERIENCE && tokenStats.generation == 0;
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

        // You may also set sponsorship for the collection to create a fee-less experience:
        // import {UniqueNFT} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
        // UniqueNFT collection = UniqueNFT(collectionAddress);
        // collection.setCollectionSponsorCross(CrossAddress({eth: address(this), sub: 0}));
        // collection.confirmCollectionSponsorship();

        return collectionAddress;
    }

    /**
     * @dev Internal function to conduct a fight between two tokens.
     * @param _tokenId1 ID of the first token.
     * @param _tokenId2 ID of the second token.
     */
    function _fight(uint256 _tokenId1, uint256 _tokenId2) private {
        // Randomly decide the winner and loser.
        (uint256 winner, uint256 loser) = _getPseudoRandom(2, 0) == 0 ? (_tokenId1, _tokenId2) : (_tokenId2, _tokenId1);

        // Update winner's stats.
        TokenStats memory winnerStats = s_tokenStats[winner];
        winnerStats.victories += 1;
        winnerStats.experience += 50;
        s_tokenStats[winner] = winnerStats;

        // Update loser's stats.
        TokenStats memory loserStats = s_tokenStats[loser];
        loserStats.defeats += 1;
        loserStats.experience += 10;
        s_tokenStats[loser] = loserStats;

        // Update winner's token attributes.
        COLLECTION_ADDRESS.setTrait(winner, "Experience", Converter.uint2bytes(winnerStats.experience));
        COLLECTION_ADDRESS.setTrait(winner, "Victories", Converter.uint2bytes(winnerStats.victories));

        // Update loser's token attributes.
        COLLECTION_ADDRESS.setTrait(loser, "Experience", Converter.uint2bytes(loserStats.experience));
        COLLECTION_ADDRESS.setTrait(loser, "Defeats", Converter.uint2bytes(loserStats.defeats));

        // Make the loser exhausted (change NFT's image).
        _makeExhausted(loser);

        delete s_gladiator;
    }

    /**
     * @dev Changes an NFT's image to exhausted version.
     *      Note: Currently, there is no cooldown period before recovery.
     * @param _tokenId ID of the token to mark as exhausted.
     */
    function _makeExhausted(uint256 _tokenId) private {
        _setImage(_tokenId, true);
        // TODO: we can set a cooldown period to recover the token
    }

    /**
     * @dev Updates the image of a token to exhausted or to normal state.
     * @param _tokenId ID of the token.
     * @param _exhausted Boolean indicating whether the token is exhausted.
     */
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

    /**
     * @dev Generates a pseudo-random number.
     * @param _modulo The modulo to apply to the random number.
     * @param startFrom The starting number to add to the random result.
     * @return A pseudo-random uint32 number.
     */
    function _getPseudoRandom(uint256 _modulo, uint256 startFrom) private view returns (uint32) {
        uint256 randomHash = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)));

        return uint32((randomHash % _modulo) + startFrom);
    }
}
