// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {FactoryStorage} from "../storage/FactoryStorage.sol";

interface IFactoryOwnable {
    error ErrCreateCollectionFailed();

    event CreateCollection(
        string name,
        string symbol,
        address indexed tokenAddress
    );

    function createCollection(
        string memory name,
        string memory symbol,
        string memory uri,
        address royaltyReceiver,
        uint256 royaltyPercentage,
        bool isERC1155,
        address trustedForwarder
    ) external;

    function collections()
        external
        view
        returns (FactoryStorage.Collection[] memory);
}
