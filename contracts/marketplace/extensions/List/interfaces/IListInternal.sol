// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IListInternal {
    event ListingAdd(
        uint256 indexed listingId,
        address indexed seller,
        address indexed tokenAddress,
        uint256 tokenId,
        uint256 quantity,
        uint256 priceInUsd,
        uint256 time
    );
    event UpdateListing(
        uint256 indexed listingId,
        address indexed tokenAddress,
        uint256 quantity,
        uint256 priceInUsd,
        uint256 time
    );

    event CancelListing(
        address indexed tokenAddress,
        address indexed owner,
        uint256 tokeId,
        uint256 listingId,
        uint256 time
    );
}
