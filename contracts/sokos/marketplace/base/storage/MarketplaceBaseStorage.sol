// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library MarketplaceBaseStorage {
    struct TokenFeed {
        address feed;
        uint8 decimals;
    }

    struct Layout {
        uint104 sokosFee;
        uint104 mintFee;
        uint8 sokosDecimals;
        address payable feeReceipient;
        mapping(address => TokenFeed) payableToken;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("SOKOS.contracts.storage.marketplace-base");

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
