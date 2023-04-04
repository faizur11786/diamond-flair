// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library ERC20SupplyAdminStorage {
    struct Layout {
        bool maxSupplyFrozen;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("v2.flair.contracts.storage.ERC20SupplyAdmin");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
