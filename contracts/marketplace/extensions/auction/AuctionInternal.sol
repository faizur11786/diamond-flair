// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../../base/MarketplaceBaseInternal.sol";
import {IAuctionInternal} from "./interfaces/IAuctionInternal.sol";
import {AuctionStorage} from "./storage/AuctionStorage.sol";
import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";

abstract contract AuctionInternal is IAuctionInternal, MarketplaceBaseInternal {
    using AuctionStorage for AuctionStorage.Layout;

    function _createAuction(
        address _nft,
        uint256 _tokenId,
        address _payToken,
        uint256 _price,
        uint256 _minBid,
        uint256 _startTime,
        uint256 _endTime
    ) internal virtual {
        IERC721 nft = IERC721(_nft);
        require(nft.ownerOf(_tokenId) == _msgSender(), "not nft owner");
        require(_endTime > _startTime, "invalid end time");

        nft.transferFrom(_msgSender(), address(this), _tokenId);
        AuctionStorage.layout().auctionNfts[_nft][_tokenId] = AuctionStorage
            .AuctionNFT({
                nft: _nft,
                tokenId: _tokenId,
                creator: _msgSender(),
                payToken: _payToken,
                initialPrice: _price,
                minBid: _minBid,
                startTime: _startTime,
                endTime: _endTime,
                lastBidder: address(0),
                heighestBid: _price,
                winner: address(0),
                success: false
            });
        emit CreatedAuction(
            _nft,
            _tokenId,
            _payToken,
            _price,
            _minBid,
            _startTime,
            _endTime,
            _msgSender()
        );
    }

    function _cancelAuction(address _nft, uint256 _tokenId) internal virtual {
        AuctionStorage.AuctionNFT memory auction = AuctionStorage
            .layout()
            .auctionNfts[_nft][_tokenId];
        require(auction.creator == _msgSender(), "not auction creator");
        require(block.timestamp < auction.startTime, "auction already started");
        require(auction.lastBidder == address(0), "already have bidder");
        IERC721 nft = IERC721(_nft);

        nft.transferFrom(address(this), _msgSender(), _tokenId);

        delete AuctionStorage.layout().auctionNfts[_nft][_tokenId];
    }

    function bidPlace(
        address nft,
        uint256 tokenId,
        uint256 bidPrice
    ) internal virtual {}

    function resultAuction(address nft, uint256 tokenId) internal virtual {}
}
