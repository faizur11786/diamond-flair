// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IOfferExtension {
    function offer(
        address payToken,
        uint256 listingId,
        uint256 quantity,
        uint offerPrice,
        uint256 expAt
    ) external returns (bool);
}
