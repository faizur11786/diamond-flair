// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../../../access/ownable/OwnableInternal.sol";
import "../../base/MarketplaceBaseInternal.sol";
import {IERC1155ListInternal} from "./interfaces/IERC1155ListInternal.sol";
// import {ISokosNFT} from "./interfaces/ISokosNFT.sol";
import {ERC1155ListStorage} from "./storage/ERC1155ListStorage.sol";
import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";

abstract contract ERC1155ListInternal is
    OwnableInternal,
    IERC1155ListInternal,
    MarketplaceBaseInternal
{
    using ERC1155ListStorage for ERC1155ListStorage.Layout;

    function _createERC1155Listing(
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _priceInUsd
    ) internal {
        IERC1155 erc1155Token = IERC1155(_tokenAddress);

        require(
            erc1155Token.balanceOf(_msgSender(), _tokenId) >= _quantity,
            "Not enough ERC1155 token"
        );
        require(
            erc1155Token.isApprovedForAll(_msgSender(), address(this)),
            "Not approved for transfer"
        );
        ERC1155ListStorage.Layout storage l = ERC1155ListStorage.layout();

        uint256 listingId = l.erc1155TokenToListingId[_tokenAddress][_tokenId][
            _msgSender()
        ];

        if (listingId == 0) {
            uint256 listId = l.nextListingId++;

            l.listingIds.push(listId);
            l.erc1155TokenToListingId[_tokenAddress][_tokenId][
                _msgSender()
            ] = listId;
            l.erc1155Listings[listId] = ERC1155ListStorage.ERC1155Listing({
                listingId: listId,
                seller: _msgSender(),
                tokenAddress: _tokenAddress,
                tokenId: _tokenId,
                quantity: _quantity,
                boughtQuantity: 0,
                priceInUsd: _priceInUsd,
                timeCreated: block.timestamp,
                timeLastPurchased: 0,
                sourceListingId: 0,
                sold: false,
                cancelled: false
            });

            emit ERC1155ListingAdd(
                listId,
                _msgSender(),
                _tokenAddress,
                _tokenId,
                _quantity,
                _priceInUsd,
                block.timestamp
            );
        } else {
            ERC1155ListStorage.ERC1155Listing memory listing = l
                .erc1155Listings[listingId];
            listing.quantity = _quantity;
            listing.priceInUsd = _priceInUsd;
            emit UpdateERC1155Listing(
                listingId,
                _tokenAddress,
                _quantity,
                _priceInUsd,
                block.timestamp
            );
        }
    }

    // function _ERC1155ListNft(
    //     address _nft,
    //     uint256 _tokenId,
    //     address _payToken,
    //     uint256 _price
    // ) external isPayableToken(_payToken) {
    //     IERC721 nft = IERC721(_nft);
    //     require(nft.ownerOf(_tokenId) == msg.sender, "not nft owner");
    //     nft.transferFrom(msg.sender, address(this), _tokenId);
    //     ERC1155ListNfts[_nft][_tokenId] = ERC1155ListNFT({
    //         nft: _nft,
    //         tokenId: _tokenId,
    //         seller: msg.sender,
    //         payToken: _payToken,
    //         price: _price,
    //         sold: false
    //     });
    //     emit ERC1155ListedNFT(_nft, _tokenId, _payToken, _price, msg.sender);
    // }
}
