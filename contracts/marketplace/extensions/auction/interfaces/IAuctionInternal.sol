// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IAuctionInternal {
    error ErrMaxSupplyExceeded();
    event CreatedAuction(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 price,
        uint256 minBid,
        uint256 startTime,
        uint256 endTime,
        address indexed creator
    );
    event PlacedBid(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 bidPrice,
        address indexed bidder
    );
    event ResultedAuction(
        address indexed nft,
        uint256 indexed tokenId,
        address creator,
        address indexed winner,
        uint256 price,
        address caller
    );
}
