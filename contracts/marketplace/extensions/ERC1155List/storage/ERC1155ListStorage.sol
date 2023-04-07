// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library ERC1155ListStorage {
    struct ERC1155Listing {
        uint256 listingId;
        address seller;
        address tokenAddress;
        uint256 tokenId;
        uint256 quantity;
        uint256 boughtQuantity;
        uint256 priceInUsd;
        uint256 timeCreated;
        uint256 timeLastPurchased;
        uint256 sourceListingId;
        bool sold;
        bool cancelled;
    }
    struct Layout {
        uint256 nextListingId;
        mapping(uint256 => ERC1155Listing) erc1155Listings;
        mapping(address => mapping(uint256 => mapping(address => uint256))) erc1155TokenToListingId;
        uint256[] listingIds;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("sokos.contracts.storage.bid");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
