// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library OfferStorage {
    struct OfferNFT {
        address nft;
        uint256 tokenId;
        address offerer;
        address payToken;
        uint256 offerPrice;
        bool accepted;
    }
    struct Layout {
        // nft => tokenId => offerer address => offer struct
        mapping(address => mapping(uint256 => mapping(address => OfferNFT))) offerNfts;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("sokos.contracts.storage.offer");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
