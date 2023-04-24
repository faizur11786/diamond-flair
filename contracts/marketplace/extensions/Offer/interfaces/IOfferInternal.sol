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
}
