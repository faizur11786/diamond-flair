// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library FactoryStorage {
    struct Layout {
        mapping(address => bool) sokosNFT;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("SOKOS.contracts.storage.factory");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
