// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library ERC20SupplyStorage {
    struct Layout {
        // Maximum possible supply of tokens.
        uint256 maxSupply;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("sokos.contracts.storage.bid");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
