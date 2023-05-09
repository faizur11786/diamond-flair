// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAuctionInternal} from "./interfaces/IAuctionInternal.sol";
import {ISokosNFT} from "./interfaces/ISokosNFT.sol";

import {OwnableInternal} from "../../../access/ownable/OwnableInternal.sol";
import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";
import {AuctionStorage} from "./storage/AuctionStorage.sol";

// import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";

abstract contract AuctionInternal is
    OwnableInternal,
    IAuctionInternal,
    MarketplaceBaseInternal
{
    using AuctionStorage for AuctionStorage.Layout;

    modifier isAuction(address _nft, uint256 _tokenId) {
        AuctionStorage.AuctionNFT memory auction = AuctionStorage
            .layout()
            .auctionNfts[_nft][_tokenId];
        require(
            auction.nft != address(0) && !auction.success,
            "auction already created"
        );
        _;
    }

    modifier isNotAuction(address _nft, uint256 _tokenId) {
        AuctionStorage.AuctionNFT memory auction = AuctionStorage
            .layout()
            .auctionNfts[_nft][_tokenId];
        require(
            auction.nft == address(0) || auction.success,
            "auction already created"
        );
        _;
    }

    function _calculateRoyalty(
        uint256 _royalty,
        uint256 _price
    ) internal pure returns (uint256) {
        return (_price * _royalty) / 10000;
    }

    function _calculatePlatformFee(
        uint256 _price
    ) internal view returns (uint256) {
        return (_price * _fee()) / 10000;
    }

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

    function _bidPlace(
        address _nft,
        uint256 _tokenId,
        uint256 _bidPrice
    ) internal virtual {
        AuctionStorage.AuctionNFT memory auction = AuctionStorage
            .layout()
            .auctionNfts[_nft][_tokenId];
        require(block.timestamp >= auction.startTime, "auction not start");
        require(block.timestamp <= auction.endTime, "auction ended");
        require(
            _bidPrice >= auction.heighestBid + auction.minBid,
            "less than min bid price"
        );

        // AuctionNFT storage auction = auctionNfts[_nft][_tokenId];
        IERC20 payToken = IERC20(auction.payToken);
        payToken.transferFrom(_msgSender(), address(this), _bidPrice);

        if (auction.lastBidder != address(0)) {
            address lastBidder = auction.lastBidder;
            uint256 lastBidPrice = auction.heighestBid;

            // Transfer back to last bidder
            payToken.transfer(lastBidder, lastBidPrice);
        }

        // Set new heighest bid price
        auction.lastBidder = _msgSender();
        auction.heighestBid = _bidPrice;

        emit PlacedBid(
            _nft,
            _tokenId,
            auction.payToken,
            _bidPrice,
            _msgSender()
        );
    }

    function _resultAuction(address _nft, uint256 _tokenId) internal virtual {
        AuctionStorage.AuctionNFT memory auction = AuctionStorage
            .layout()
            .auctionNfts[_nft][_tokenId];
        require(!auction.success, "already resulted");
        require(
            _msgSender() == _owner() ||
                _msgSender() == auction.creator ||
                _msgSender() == auction.lastBidder,
            "not creator, winner, or owner"
        );
        require(block.timestamp > auction.endTime, "auction not ended");

        // AuctionNFT storage auction = auctionNfts[_nft][_tokenId];
        IERC20 payToken = IERC20(auction.payToken);
        IERC721 nft = IERC721(auction.nft);

        auction.success = true;
        auction.winner = auction.creator;

        ISokosNFT sokosNft = ISokosNFT(_nft);
        address royaltyRecipient = sokosNft.getRoyaltyRecipient();
        uint256 royaltyFee = sokosNft.getRoyaltyFee();

        uint256 heighestBid = auction.heighestBid;
        uint256 totalPrice = heighestBid;

        if (royaltyFee > 0) {
            uint256 royaltyTotal = _calculateRoyalty(royaltyFee, heighestBid);

            // Transfer royalty fee to collection owner
            payToken.transfer(royaltyRecipient, royaltyTotal);
            totalPrice -= royaltyTotal;
        }

        // Calculate & Transfer platfrom fee
        uint256 platformFeeTotal = _calculatePlatformFee(heighestBid);
        payToken.transfer(_feeReceipient(), platformFeeTotal);

        // Transfer to auction creator
        payToken.transfer(auction.creator, totalPrice - platformFeeTotal);

        // Transfer NFT to the winner
        nft.transferFrom(address(this), auction.lastBidder, auction.tokenId);

        emit ResultedAuction(
            _nft,
            _tokenId,
            auction.creator,
            auction.lastBidder,
            auction.heighestBid,
            _msgSender()
        );
    }
}
