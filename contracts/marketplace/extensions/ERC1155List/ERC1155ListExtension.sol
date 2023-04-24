// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

import "../../base/MarketplaceBaseInternal.sol";
import "./interfaces/IERC1155ListInternal.sol";
import "./interfaces/IERC1155ListExtension.sol";
import {ERC1155ListInternal} from "./ERC1155ListInternal.sol";
import {ERC1155ListStorage} from "./storage/ERC1155ListStorage.sol";

abstract contract ERC1155ListExtension is
    IERC1155ListExtension,
    ERC1155ListInternal
{
    using ERC1155ListStorage for ERC1155ListStorage.Layout;

    function createERC1155Listing(
        address tokenAddress,
        uint256 tokenId,
        uint256 quantity,
        uint256 priceInUsd
    ) external virtual {
        _createERC1155Listing(tokenAddress, tokenId, quantity, priceInUsd);
    }

    function listingIds() external view returns (uint256[] memory) {
        return ERC1155ListStorage.layout().listingIds;
    }

    function listedNFT(
        uint256 listingId
    ) external view returns (ERC1155ListStorage.ERC1155Listing memory) {
        return _listedNFT(listingId);
    }

    function listedNFTs()
        external
        view
        returns (ERC1155ListStorage.ERC1155Listing[] memory)
    {
        return _listedNFTs();
    }

    function listedNFTsByIDs(
        uint256[] calldata ids
    ) external view returns (ERC1155ListStorage.ERC1155Listing[] memory) {
        return _listedNFTsByIDs(ids);
    }
}
