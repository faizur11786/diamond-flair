// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IListInternal} from "./interfaces/IListInternal.sol";
import {IListExtension} from "./interfaces/IListExtension.sol";

import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";
import {ListStorage} from "./storage/ListStorage.sol";
import {ListInternal} from "./ListInternal.sol";

abstract contract ListExtension is IListExtension, ListInternal {
    function createListing(
        address payToken,
        address tokenAddress,
        uint256 tokenId,
        uint256 quantity,
        uint256 priceInUsd
    ) external virtual {
        _createListing(payToken, tokenAddress, tokenId, quantity, priceInUsd);
    }

    function cancelListing(
        address tokenAddress,
        uint256 tokenId,
        uint256 listingId
    ) external virtual isListed(listingId) returns (bool) {
        bool success = _cancelListing(tokenAddress, tokenId, _msgSender());
        if (!success) {
            revert ErrCancelListingFailed();
        }
        return success;
    }

    function listingIds() external view returns (uint256[] memory) {
        return ListStorage.layout().listingIds;
    }

    function listedNFT(
        uint256 listingId
    ) external view returns (ListStorage.Listing memory) {
        return _listedNFT(listingId);
    }

    function listedNFTs() external view returns (ListStorage.Listing[] memory) {
        return _listedNFTs();
    }

    function listedNFTsByIDs(
        uint256[] calldata ids
    ) external view returns (ListStorage.Listing[] memory) {
        return _listedNFTsByIDs(ids);
    }

    function listedNFTbyOwner(
        address owner,
        address tokenAddress,
        uint256 tokenId
    ) external view returns (ListStorage.Listing memory) {
        return _listedNFTbyOwner(owner, tokenAddress, tokenId);
    }

    function nowTime() external view returns (uint256) {
        return block.timestamp;
    }

    function getListingId(
        address owner,
        address tokenAddress,
        uint256 tokenId
    ) external view returns (uint256) {
        return _getListingId(owner, tokenAddress, tokenId);
    }
}
