// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {ERC1155ListStorage} from "../storage/ERC1155ListStorage.sol";

interface IERC1155ListExtension {
    function createERC1155Listing(
        address tokenAddress,
        uint256 tokenId,
        uint256 quantity,
        uint256 priceInUsd
    ) external;

    function listedNFT(
        uint256 listingId
    ) external view returns (ERC1155ListStorage.ERC1155Listing memory);

    function listedNFTs()
        external
        view
        returns (ERC1155ListStorage.ERC1155Listing[] memory);

    function listingIds() external view returns (uint256[] memory);

    function listedNFTsByIDs(
        uint256[] calldata ids
    ) external view returns (ERC1155ListStorage.ERC1155Listing[] memory);
}
