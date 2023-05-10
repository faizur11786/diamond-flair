// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IMarketplaceBaseInternal {
    event BoughtNFT(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 price,
        address seller,
        address indexed buyer
    );
}
