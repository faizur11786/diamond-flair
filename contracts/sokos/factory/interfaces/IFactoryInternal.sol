// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IFactoryInternal {
    error ErrDuplicateCollection();
    event AddCollection(
        address indexed tokenAddress,
        string name,
        string symbol,
        bool isERC1155
    );
    event CollectionDeployed(address indexed tokenAddress);
}
