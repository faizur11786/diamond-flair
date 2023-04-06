// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library AuctionStorage {
    struct AuctionNFT {
        address nft;
        uint256 tokenId;
        address creator;
        address payToken;
        uint256 initialPrice;
        uint256 minBid;
        uint256 startTime;
        uint256 endTime;
        address lastBidder;
        uint256 heighestBid;
        address winner;
        bool success;
    }
    struct ListNFT {
        address nft;
        uint256 tokenId;
        address seller;
        address payToken;
        uint256 price;
        bool sold;
    }

    struct OfferNFT {
        address nft;
        uint256 tokenId;
        address offerer;
        address payToken;
        uint256 offerPrice;
        bool accepted;
    }

    struct Layout {
        // nft => tokenId => acution struct
        mapping(address => mapping(uint256 => AuctionNFT)) auctionNfts;
        // nft => tokenId => list struct
        mapping(address => mapping(uint256 => ListNFT)) listNfts;
        // nft => tokenId => offerer address => offer struct
        mapping(address => mapping(uint256 => mapping(address => OfferNFT))) offerNfts;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("SOKOS.contracts.storage.auction");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
