// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IOfferInternal} from "./interfaces/IOfferInternal.sol";
import {OfferStorage} from "./storage/OfferStorage.sol";
import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";
import {ListStorage} from "../list/storage/ListStorage.sol";

abstract contract OfferInternal is IOfferInternal, MarketplaceBaseInternal {
    using OfferStorage for OfferStorage.Layout;

    modifier isOfferred(address offerer, uint256 listId) {
        OfferStorage.Layout storage l = OfferStorage.layout();
        OfferStorage.OfferNFT memory offer = l.offerNfts[listId][offerer];
        require(
            offer.offerPrice > 0 && offer.offerer != address(0),
            "NOT_OFFERRED"
        );
        _;
    }

    function _offer(
        address payToken,
        uint256 listingId,
        uint256 quantity,
        uint256 offerPrice,
        uint256 expAt
    ) internal returns (bool) {
        OfferStorage.Layout storage l = OfferStorage.layout();
        ListStorage.Layout storage listL = ListStorage.layout();
        ListStorage.Listing memory listing = listL.listings[listingId];

        l.offerNfts[listingId][_msgSender()] = OfferStorage.OfferNFT({
            tokenAddress: listing.tokenAddress,
            tokenId: listing.tokenId,
            offerer: _msgSender(),
            payToken: payToken,
            quantity: quantity,
            offerPrice: offerPrice,
            accepted: false,
            expAt: expAt
        });
        emit OfferCreated(listingId, _msgSender(), payToken, offerPrice, expAt);
        return true;
    }

    function _accept(address token) internal returns (bool) {
        // if (
        //     IERC165(listed.tokenAddress).supportsInterface(INTERFACE_ID_ERC2981)
        // ) {
        //     (address royaltiesReceiver, uint256 royaltiesAmount) = IERC2981(
        //         listed.tokenAddress
        //     ).royaltyInfo(listed.tokenId, price);
        //     if (royaltiesAmount > 0 && royaltiesReceiver != address(0)) {
        //         // Pay Royalty
        //     }
        // }
        // IERC1155 erc1155Token;
        // IERC721 erc721Token;
        // if (
        //     IERC165(listed.tokenAddress).supportsInterface(INTERFACE_ID_ERC721)
        // ) {
        //     erc721Token = IERC721(listed.tokenAddress);
        //     require(
        //         erc721Token.ownerOf(listed.tokenId) == _msgSender(),
        //         "Not owning item"
        //     );
        //     require(
        //         erc721Token.isApprovedForAll(_msgSender(), address(this)),
        //         "Not approved for transfer"
        //     );
        //     return true;
        // } else if (
        //     IERC165(listed.tokenAddress).supportsInterface(INTERFACE_ID_ERC1155)
        // ) {
        //     erc1155Token = IERC1155(listed.tokenAddress);
        //     require(
        //         erc1155Token.balanceOf(_msgSender(), listed.tokenId) >=
        //             offered.quantity,
        //         "Not enough ERC1155 token"
        //     );
        //     require(
        //         erc1155Token.isApprovedForAll(_msgSender(), address(this)),
        //         "Not approved for transfer"
        //     );
        //     return true;
        // } else {
        //     revert ErrInvalidNFT();
        // }
        // return true;
    }

    function _afterOfferAccept(
        uint256 listId,
        address offerer,
        address seller,
        address payToken,
        uint256 pricePiad
    ) internal {
        emit OfferAccepted(listId, offerer, seller, payToken, pricePiad);
    }
}
