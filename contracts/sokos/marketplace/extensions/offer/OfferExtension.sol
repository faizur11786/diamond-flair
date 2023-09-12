// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC2981, IERC165} from "@openzeppelin/contracts/interfaces/IERC2981.sol";

import {IERC721, IERC165} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IOfferExtension} from "./interfaces/IOfferExtension.sol";
import {OfferInternal} from "./OfferInternal.sol";
import {ListStorage} from "../list/storage/ListStorage.sol";
import {OfferStorage} from "./storage/OfferStorage.sol";
import {ListInternal} from "../list/ListInternal.sol";
import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";

abstract contract OfferExtension is
    IOfferExtension,
    MarketplaceBaseInternal,
    ListInternal,
    OfferInternal
{
    using OfferStorage for OfferStorage.Layout;

    function offer(
        address payToken,
        uint256 listId,
        uint256 quantity,
        uint256 offerPrice,
        uint256 expAt
    ) external isListed(listId) returns (bool) {
        require(payToken != address(0), "ADDRESS_ZERO");
        require(offerPrice > 0, "PRICE_ZERO");
        require(expAt > block.timestamp, "EXP_INVALID");
        ERC20 paytoken = ERC20(payToken);
        paytoken.approve(address(this), offerPrice * quantity);

        _offer(payToken, listId, quantity, offerPrice, expAt);
        return true;
    }

    function offerOf(
        address offerer,
        uint256 listId
    ) external view returns (OfferStorage.OfferNFT memory) {
        OfferStorage.Layout storage l = OfferStorage.layout();
        return l.offerNfts[listId][offerer];
    }

    function cancelOffer(
        uint256 listId
    ) external isOfferred(_msgSender(), listId) returns (bool) {
        OfferStorage.Layout storage l = OfferStorage.layout();
        OfferStorage.OfferNFT memory offered = l.offerNfts[listId][
            _msgSender()
        ];
        require(offered.offerer == _msgSender(), "NOT_OFFERER");
        require(!offered.accepted, "ACCEPTED");
        delete l.offerNfts[listId][_msgSender()];
        emit CanceledOfferred(
            offered.tokenAddress,
            listId,
            offered.offerer,
            offered.payToken,
            offered.offerPrice
        );
        return true;
    }

    event Fee(uint256 feeAmount, uint256 price);

    function acceptOffer(
        uint256 listId,
        address offerer
    ) external isListed(listId) isOfferred(_msgSender(), listId) {
        OfferStorage.Layout storage ol = OfferStorage.layout();
        ListStorage.Layout storage ll = ListStorage.layout();
        OfferStorage.OfferNFT memory offered = ol.offerNfts[listId][offerer];
        ListStorage.Listing memory listed = ll.listings[listId];
        require(listed.seller == _msgSender(), "NOT_SELLER");
        require(offered.expAt > block.timestamp, "BID_EXPIRED");
        require(!listed.sold, "ALREADY_SOLD");
        require(!offered.accepted, "ALREADY_ACCEPTED");

        require(_decimals() > 0, "SOKOS_CONFIG");

        offered.accepted = true;
        listed.timeLastPurchased = block.timestamp;
        listed.boughtQuantity = 1;

        if (listed.quantity == 1) {
            listed.sold = true;
        }

        {
            ERC20 paytoken = ERC20(offered.payToken);

            uint256 feeAmount = (_fee() * 10 ** paytoken.decimals()) /
                10 ** _decimals();
            uint256 price = offered.offerPrice * offered.quantity - feeAmount;

            emit Fee(feeAmount, price);

            if (
                IERC165(listed.tokenAddress).supportsInterface(
                    INTERFACE_ID_ERC2981
                )
            ) {
                (address royaltiesReceiver, uint256 royaltiesAmount) = IERC2981(
                    listed.tokenAddress
                ).royaltyInfo(listed.tokenId, price);
                if (royaltiesAmount > 0 && royaltiesReceiver != address(0)) {
                    price -= royaltiesAmount;
                    // Transfer royalty fee to collection owner
                    paytoken.transferFrom(
                        offered.offerer,
                        royaltiesReceiver,
                        royaltiesAmount
                    );
                }
            }

            // Transfer platfrom fee
            paytoken.transferFrom(offered.offerer, _feeReceipient(), feeAmount);
            // Transfer to seller
            paytoken.transferFrom(offered.offerer, listed.seller, price);
        }
        IERC1155 erc1155Token;
        IERC721 erc721Token;
        if (
            IERC165(listed.tokenAddress).supportsInterface(INTERFACE_ID_ERC721)
        ) {
            erc721Token = IERC721(listed.tokenAddress);
            require(
                erc721Token.ownerOf(listed.tokenId) == _msgSender(),
                "Not owning item"
            );
            require(
                erc721Token.isApprovedForAll(_msgSender(), address(this)),
                "Not approved for transfer"
            );
            // Transfer NFT to offerer
            erc721Token.transferFrom(
                _msgSender(),
                offered.offerer,
                listed.tokenId
            );
        } else if (
            IERC165(listed.tokenAddress).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            erc1155Token = IERC1155(listed.tokenAddress);
            require(
                erc1155Token.balanceOf(_msgSender(), listed.tokenId) >=
                    offered.quantity,
                "Not enough ERC1155 token"
            );
            require(
                erc1155Token.isApprovedForAll(_msgSender(), address(this)),
                "Not approved for transfer"
            );
            // Transfer NFT to offerer
            erc1155Token.safeTransferFrom(
                _msgSender(),
                offered.offerer,
                listed.tokenId,
                offered.quantity,
                "0x"
            );
        } else {
            revert ErrInvalidNFT();
        }
        _afterOfferAccept(
            listId,
            offered.offerer,
            listed.seller,
            offered.payToken,
            offered.offerPrice * offered.quantity
        );
    }
}
