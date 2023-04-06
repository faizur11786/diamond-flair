// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IMarketplaceBase} from "./interfaces/IMarketplaceBase.sol";
import {MarketplaceBaseInternal} from "./MarketplaceBaseInternal.sol";
import {MarketplaceBaseStorage} from "./storage/MarketplaceBaseStorage.sol";

/**
 * @title Base ERC20 implementation, excluding optional extensions
 */
abstract contract MarketplaceBase is IMarketplaceBase, MarketplaceBaseInternal {
    function fee() external view returns (uint16) {
        return _fee();
    }

    function mintFee() external view returns (uint16) {
        return _mintFee();
    }

    function decimals() external view returns (uint8) {
        return _decimals();
    }

    function feeReceipient() external view returns (address) {
        return _feeReceipient();
    }
}
