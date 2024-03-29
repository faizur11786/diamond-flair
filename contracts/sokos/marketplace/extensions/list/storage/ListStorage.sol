// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library ListStorage {
    struct Listing {
        address seller;
        address payToken;
        address tokenAddress;
        uint256 tokenId;
        uint256 quantity;
        uint256 boughtQuantity;
        uint256 priceInUsd;
        uint256 timeCreated;
        uint256 timeLastPurchased;
        bool sold;
        bool isActive;
    }
    struct Layout {
        uint256 nextListingId;
        mapping(uint256 => Listing) listings;
        mapping(address => mapping(uint256 => mapping(address => uint256))) tokenToListingId;
        uint256[] listingIds;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("sokos.contracts.storage.listing");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
