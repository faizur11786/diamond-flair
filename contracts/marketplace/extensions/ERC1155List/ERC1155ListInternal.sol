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
        IERC1155 erc1155Token;
        IERC721 erc721Token;
        if (IERC165(_tokenAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            erc721Token = IERC721(_tokenAddress);
            require(
                erc721Token.ownerOf(_tokenId) == _msgSender(),
                "Not owning item"
            );
            require(
                erc721Token.isApprovedForAll(_msgSender(), address(this)),
                "Not approved for transfer"
            );
        } else if (
            IERC165(_tokenAddress).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            erc1155Token = IERC1155(_tokenAddress);
            require(
                erc1155Token.balanceOf(_msgSender(), _tokenId) >= _quantity,
                "Not enough ERC1155 token"
            );
            require(
                erc1155Token.isApprovedForAll(_msgSender(), address(this)),
                "Not approved for transfer"
            );
        } else {
            revert("INVALID_NFT");
        }

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

    function _listedNFT(
        uint256 listingId
    ) internal view returns (ERC1155ListStorage.ERC1155Listing memory) {
        ERC1155ListStorage.Layout storage l = ERC1155ListStorage.layout();
        return l.erc1155Listings[listingId];
    }

    function _listedNFTs()
        internal
        view
        returns (ERC1155ListStorage.ERC1155Listing[] memory)
    {
        ERC1155ListStorage.Layout storage l = ERC1155ListStorage.layout();
        uint256 length = l.listingIds.length;
        ERC1155ListStorage.ERC1155Listing[]
            memory nfts = new ERC1155ListStorage.ERC1155Listing[](
                l.listingIds.length
            );
        for (uint i = 0; i < length; i++) {
            ERC1155ListStorage.ERC1155Listing storage nft = l.erc1155Listings[
                l.listingIds[i]
            ];
            nfts[i] = nft;
        }
        return nfts;
    }

    function _listedNFTsByIDs(
        uint256[] calldata ids
    ) internal view returns (ERC1155ListStorage.ERC1155Listing[] memory) {
        ERC1155ListStorage.ERC1155Listing[]
            memory nfts = new ERC1155ListStorage.ERC1155Listing[](ids.length);
        ERC1155ListStorage.Layout storage l = ERC1155ListStorage.layout();
        for (uint i = 0; i < ids.length; i++) {
            ERC1155ListStorage.ERC1155Listing storage nft = l.erc1155Listings[
                ids[i]
            ];
            nfts[i] = nft;
        }
        return nfts;
    }
}
