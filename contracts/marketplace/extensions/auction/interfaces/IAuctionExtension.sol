// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/**
 * @dev Extension of {ERC20} that tracks supply and defines a max supply cap.
 */
interface IAuctionExtension {
    function createAuction(
        address nft,
        uint256 tokenId,
        address payToken,
        uint256 price,
        uint256 minBid,
        uint256 startTime,
        uint256 endTime
    ) external;

    function cancelAuction(address nft, uint256 tokenId) external;

    function bidPlace(address nft, uint256 tokenId, uint256 bidPrice) external;

    function resultAuction(address nft, uint256 tokenId) external;
}
