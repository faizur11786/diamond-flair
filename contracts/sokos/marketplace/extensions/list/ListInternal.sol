// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC721, IERC165} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IListInternal} from "./interfaces/IListInternal.sol";

import {OwnableInternal} from "../../../../access/ownable/OwnableInternal.sol";
import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";
import {ListStorage} from "./storage/ListStorage.sol";

abstract contract ListInternal is
    OwnableInternal,
    IListInternal,
    MarketplaceBaseInternal
{
    using ListStorage for ListStorage.Layout;

    function _cancelListing(
        address _tokenAddress,
        uint256 _tokenId,
        address _owner
    ) internal returns (bool) {
        ListStorage.Layout storage l = ListStorage.layout();
        uint256 listingId = l.tokenToListingId[_tokenAddress][_tokenId][_owner];
        for (uint i = 0; i < l.listingIds.length; i++) {
            if (l.listingIds[i] == listingId) {
                ListStorage.Listing storage listing = l.listings[listingId];
                require(listing.seller == _owner, "UNAUTHORIZED_OWNER");
                listing.isActive = false;
                l.listingIds[i] = l.listingIds[l.listingIds.length - 1];
                l.listingIds.pop();
                emit CancelListing(
                    _tokenAddress,
                    _owner,
                    _tokenId,
                    listingId,
                    block.timestamp
                );
                return true;
            }
        }
        return false;
    }

    function _createListing(
        address _payToken,
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
            revert ErrInvalidNFT();
        }

        ListStorage.Layout storage l = ListStorage.layout();

        uint256 listingId = l.tokenToListingId[_tokenAddress][_tokenId][
            _msgSender()
        ];

        if (listingId == 0) {
            uint256 listId = l.nextListingId++;

            l.listingIds.push(listId);
            l.tokenToListingId[_tokenAddress][_tokenId][_msgSender()] = listId;
            l.listings[listId] = ListStorage.Listing({
                seller: _msgSender(),
                payToken: _payToken,
                tokenAddress: _tokenAddress,
                tokenId: _tokenId,
                quantity: _quantity,
                boughtQuantity: 0,
                priceInUsd: _priceInUsd,
                timeCreated: block.timestamp,
                timeLastPurchased: 0,
                sold: false,
                isActive: true
            });

            emit ListingAdd(
                listId,
                _msgSender(),
                _tokenAddress,
                _tokenId,
                _quantity,
                _priceInUsd,
                block.timestamp
            );
        } else {
            ListStorage.Listing storage listing = l.listings[listingId];
            listing.quantity = _quantity;
            listing.priceInUsd = _priceInUsd;
            listing.payToken = _payToken;
            listing.isActive = true;
            listing.sold = false;
            l.listingIds.push(listingId);
            emit UpdateListing(
                listingId,
                _tokenAddress,
                _quantity,
                _priceInUsd,
                block.timestamp
            );
        }
    }

    function _listedNFT(
        uint256 _listingId
    ) internal view returns (ListStorage.Listing memory) {
        ListStorage.Layout storage l = ListStorage.layout();
        return l.listings[_listingId];
    }

    function _getListingId(
        address _owner,
        address _tokenAddress,
        uint256 _tokenId
    ) internal view returns (uint256) {
        ListStorage.Layout storage l = ListStorage.layout();
        return l.tokenToListingId[_tokenAddress][_tokenId][_owner];
    }

    function _listedNFTbyOwner(
        address _owner,
        address _tokenAddress,
        uint256 _tokenId
    ) internal view returns (ListStorage.Listing memory) {
        ListStorage.Layout storage l = ListStorage.layout();
        uint256 listingId = l.tokenToListingId[_tokenAddress][_tokenId][_owner];
        return l.listings[listingId];
    }

    function _listedNFTs()
        internal
        view
        returns (ListStorage.Listing[] memory)
    {
        ListStorage.Layout storage l = ListStorage.layout();
        uint256 length = l.listingIds.length;
        ListStorage.Listing[] memory nfts = new ListStorage.Listing[](
            l.listingIds.length
        );
        for (uint i = 0; i < length; i++) {
            ListStorage.Listing storage nft = l.listings[l.listingIds[i]];
            nfts[i] = nft;
        }
        return nfts;
    }

    function _listedNFTsByIDs(
        uint256[] calldata ids
    ) internal view returns (ListStorage.Listing[] memory) {
        ListStorage.Listing[] memory nfts = new ListStorage.Listing[](
            ids.length
        );
        ListStorage.Layout storage l = ListStorage.layout();
        for (uint i = 0; i < ids.length; i++) {
            ListStorage.Listing storage nft = l.listings[ids[i]];
            nfts[i] = nft;
        }
        return nfts;
    }

    modifier isListed(uint256 listId) {
        ListStorage.Layout storage l = ListStorage.layout();
        ListStorage.Listing memory listing = l.listings[listId];
        require(listing.isActive && listing.quantity > 0, "NOT_LISTED");
        _;
    }

    // function isListed(uint256 _listingId) public view returns (bool) {
    //     ListStorage.Layout storage l = ListStorage.layout();
    //     ListStorage.Listing memory listing = l.listings[_listingId];
    //     if (listing.cancelled) {
    //         return false;
    //     } else if (listing.sold) {
    //         return false;
    //     } else if (listing.quantity == 0) {
    //         return false;
    //     } else {
    //         return true;
    //     }
    // }
}
