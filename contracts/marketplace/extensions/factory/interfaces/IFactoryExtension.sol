// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IFactoryExtension {
    function createCollection(
        string memory name,
        string memory symbol,
        uint256 royaltyFee,
        address royaltyRecipient
    ) external returns (bool);

    function isSokosNFT(address tokenAddress) external returns (bool);
}
