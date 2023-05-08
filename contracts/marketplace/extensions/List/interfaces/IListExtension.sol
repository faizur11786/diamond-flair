// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {ListStorage} from "../storage/ListStorage.sol";

interface IListExtension {
    function createListing(
        address tokenAddress,
        uint256 tokenId,
        uint256 quantity,
        uint256 priceInUsd,
        uint256 startTime,
        uint256 endTime
    ) external;

    function cancelListing(
        address tokenAddress,
        uint256 tokenId
    ) external returns (bool);

    function listedNFT(
        uint256 listingId
    ) external view returns (ListStorage.Listing memory);

    function listedNFTs() external view returns (ListStorage.Listing[] memory);

    function listingIds() external view returns (uint256[] memory);

    function listedNFTsByIDs(
        uint256[] calldata ids
    ) external view returns (ListStorage.Listing[] memory);

    function listedNFTbyOwner(
        address owner,
        address tokenAddress,
        uint256 tokenId
    ) external view returns (ListStorage.Listing memory);
}
