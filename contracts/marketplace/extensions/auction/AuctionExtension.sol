// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

import "../../base/MarketplaceBaseInternal.sol";
import "./interfaces/IAuctionInternal.sol";
import "./interfaces/IAuctionExtension.sol";
import {AuctionInternal} from "./AuctionInternal.sol";
import {AuctionStorage} from "./storage/AuctionStorage.sol";

abstract contract AuctionExtension is IAuctionExtension, AuctionInternal {
    using AuctionStorage for AuctionStorage.Layout;

    function createAuction(
        address nft,
        uint256 tokenId,
        address payToken,
        uint256 price,
        uint256 minBid,
        uint256 startTime,
        uint256 endTime
    ) public virtual isPayableToken(payToken) isNotAuction(nft, tokenId) {
        _createAuction(
            nft,
            tokenId,
            payToken,
            price,
            minBid,
            startTime,
            endTime
        );
    }

    function cancelAuction(
        address nft,
        uint256 tokenId
    ) public virtual isAuction(nft, tokenId) {
        _cancelAuction(nft, tokenId);
    }

    function bidPlace(
        address nft,
        uint256 tokenId,
        uint256 bidPrice
    ) public virtual isAuction(nft, tokenId) {
        _bidPlace(nft, tokenId, bidPrice);
    }

    function resultAuction(address nft, uint256 tokenId) public virtual {
        _resultAuction(nft, tokenId);
    }
}
