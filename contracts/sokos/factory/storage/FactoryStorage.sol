// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library FactoryStorage {
    struct Collection {
        string name;
        string symbol;
        string uri;
        address tokenAddress;
        bool isERC1155;
    }

    struct Layout {
        Collection[] collections;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("SOKOS.contracts.storage.FactoryBase");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
