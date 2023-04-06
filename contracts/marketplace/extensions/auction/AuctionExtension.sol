// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

import "../../base/MarketplaceBaseInternal.sol";
import {AuctionStorage} from "./storage/AuctionStorage.sol";
import "./interfaces/IAuctionInternal.sol";
import "./interfaces/IAuctionExtension.sol";
import {AuctionInternal} from "./AuctionInternal.sol";

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
    ) external virtual override {
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

    // function cancelAuction(
    //     address nft,
    //     uint256 tokenId
    // ) external virtual override {}

    // function bidPlace(
    //     address nft,
    //     uint256 tokenId,
    //     uint256 bidPrice
    // ) external virtual override {}

    // function resultAuction(
    //     address nft,
    //     uint256 tokenId
    // ) external virtual override {}
    // /**
    //  * @dev See {ERC20-_beforeTokenTransfer}.
    //  */
    // function _beforeTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) internal virtual override {
    //     if (from == address(0)) {
    //         if (to != address(0)) {
    //             if (
    //                 _totalSupply() + amount >
    //                 ERC20SupplyStorage.layout().maxSupply
    //             ) {
    //                 revert ErrMaxSupplyExceeded();
    //             }
    //         }
    //     }

    //     super._beforeTokenTransfer(from, to, amount);
    // }
}
