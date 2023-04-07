// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC1155ListExtension {
    function createERC1155Listing(
        address tokenAddress,
        uint256 tokenId,
        uint256 quantity,
        uint256 priceInUsd
    ) external;
}
