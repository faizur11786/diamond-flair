// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC20Metadata} from "./interfaces/IERC20Metadata.sol";
import {ERC20MetadataInternal} from "./ERC20MetadataInternal.sol";

/**
 * @title ERC20 - Metadata
 * @notice Provides standard read methods for name, symbol and decimals metadata for an ERC20 token.
 *
 * @custom:type eip-2535-facet
 * @custom:category Tokens
 * @custom:provides-interfaces IERC20Metadata
 */
contract ERC20Metadata is IERC20Metadata, ERC20MetadataInternal {
    /**
     * @inheritdoc IERC20Metadata
     */
    function decimals() external view returns (uint8) {
        return _decimals();
    }

    function decimalsLocked() external view returns (bool) {
        return _decimalsLocked();
    }

    function name() external view returns (string memory) {
        return _name();
    }

    function symbol() external view returns (string memory) {
        return _symbol();
    }

    function nameAndSymbolLocked() external view returns (bool) {
        return _nameAndSymbolLocked();
    }
}
