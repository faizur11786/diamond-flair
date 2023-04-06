// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library MarketplaceBaseStorage {
    struct Layout {
        uint16 sokosFee;
        uint16 mintFee;
        uint8 sokosDecimals;
        address payable feeReceipient;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("SOKOS.contracts.storage.MarketplaceBase");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
