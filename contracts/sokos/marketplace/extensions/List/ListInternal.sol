// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC721, IERC165} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IListInternal} from "./interfaces/IListInternal.sol";

import {OwnableInternal} from "../../../../access/ownable/OwnableInternal.sol";
import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";
import {ListStorage} from "./storage/ListStorage.sol";

// import {ISokosNFT} from "./interfaces/ISokosNFT.sol";

// import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";

abstract contract ListInternal is
    OwnableInternal,
    IListInternal,
    MarketplaceBaseInternal
{
    using ListStorage for ListStorage.Layout;

    modifier isListedNFT(
        address _tokenAddress,
        uint256 _tokenId,
        address _owner
    ) {
        uint256 listingId = _getListingId(_owner, _tokenAddress, _tokenId);
        ListStorage.Listing memory listing = _listedNFT(listingId);
        require(!listing.cancelled, "NOT_LISTED");
        _;
    }

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
                listing.cancelled = true;
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
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _quantity,
        uint256 _priceInUsd,
        uint256 _startTime,
        uint256 _endTime
    ) internal {
        IERC1155 erc1155Token;
        IERC721 erc721Token;
        bool isERC1155;
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
            isERC1155 = true;
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
                startTime: _startTime,
                endTime: _endTime,
                sold: false,
                cancelled: false,
                isERC1155: isERC1155
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
            listing.startTime = _startTime;
            listing.endTime = _endTime;
            listing.cancelled = false;
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
}
