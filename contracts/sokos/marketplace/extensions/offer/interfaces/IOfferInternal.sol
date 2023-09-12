// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IOfferInternal {
    event OfferredNFT(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 offerPrice,
        address indexed offerer
    );

    event OfferCreated(
        uint256 indexed listingId,
        address indexed offerer,
        address payToken,
        uint256 offerPrice,
        uint256 expAt
    );

    event CanceledOfferred(
        address indexed tokenAddress,
        uint256 indexed listId,
        address indexed offerer,
        address payToken,
        uint256 offerPrice
    );
    event OfferAccepted(
        uint256 indexed listingId,
        address indexed offerer,
        address indexed seller,
        address payToken,
        uint256 pricePaid
    );
}
