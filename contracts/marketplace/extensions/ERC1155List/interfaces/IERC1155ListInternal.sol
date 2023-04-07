// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC1155ListInternal {
    event ERC1155ListingAdd(
        uint256 indexed listingId,
        address indexed seller,
        address indexed tokenAddress,
        uint256 tokenId,
        uint256 quantity,
        uint256 priceInUsd,
        uint256 time
    );
    event UpdateERC1155Listing(
        uint256 indexed listingId,
        address indexed tokenAddress,
        uint256 quantity,
        uint256 priceInUsd,
        uint256 time
    );
}
