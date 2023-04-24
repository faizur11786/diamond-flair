// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IOfferInternal} from "./interfaces/IOfferInternal.sol";
import {OfferStorage} from "./storage/OfferStorage.sol";
import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";
import {ERC1155ListStorage} from "../ERC1155List/storage/ERC1155ListStorage.sol";

abstract contract OfferInternal is IOfferInternal, MarketplaceBaseInternal {
    using OfferStorage for OfferStorage.Layout;

    modifier isOfferredNFT(
        address _nft,
        uint256 _tokenId,
        address _offerer
    ) {
        OfferStorage.OfferNFT memory offer = OfferStorage.layout().offerNfts[
            _nft
        ][_tokenId][_offerer];
        require(
            offer.offerPrice > 0 && offer.offerer != address(0),
            "not offerred nft"
        );
        _;
    }

    // @notice Offer listed NFT
    // function _offerNFT(
    //     address _nft,
    //     uint256 _tokenId,
    //     address _payToken,
    //     uint256 _offerPrice
    // ) internal {
    //     require(_offerPrice > 0, "price can not 0");

    //     if (IERC165(_nft).supportsInterface(INTERFACE_ID_ERC721)) {} else {
    //         ERC1155ListStorage.Layout storage l = ERC1155ListStorage.layout();

    //         uint256 listingId = l.erc1155TokenToListingId[_nft][_tokenId][
    //             _msgSender()
    //         ];
    //         ERC1155ListStorage.ERC1155Listing memory nft = l.erc1155Listings[
    //             listingId
    //         ];

    //         // IERC20(nft.payToken).transferFrom(
    //         //     msg.sender,
    //         //     address(this),
    //         //     _offerPrice
    //         // );
    //     }

    // ListNFT memory nft = listNfts[_nft][_tokenId];
    // IERC20(nft.payToken).transferFrom(
    //     msg.sender,
    //     address(this),
    //     _offerPrice
    // );

    // offerNfts[_nft][_tokenId][msg.sender] = OfferNFT({
    //     nft: nft.nft,
    //     tokenId: nft.tokenId,
    //     offerer: msg.sender,
    //     payToken: _payToken,
    //     offerPrice: _offerPrice,
    //     accepted: false
    // });

    // emit OfferredNFT(
    //     nft.nft,
    //     nft.tokenId,
    //     nft.payToken,
    //     _offerPrice,
    //     msg.sender
    // );
    // }
}
