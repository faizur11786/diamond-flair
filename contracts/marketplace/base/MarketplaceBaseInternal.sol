// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Context.sol";

import {IMarketplaceBaseInternal} from "./interfaces/IMarketplaceBaseInternal.sol";
import {MarketplaceBaseStorage} from "./storage/MarketplaceBaseStorage.sol";

/**
 * @title Base Marketplace internal functions, excluding optional extensions
 */
abstract contract MarketplaceBaseInternal is Context, IMarketplaceBaseInternal {
    using MarketplaceBaseStorage for MarketplaceBaseStorage.Layout;

    function _fee() internal view virtual returns (uint16) {
        return MarketplaceBaseStorage.layout().sokosFee;
    }

    function _mintFee() internal view virtual returns (uint16) {
        return MarketplaceBaseStorage.layout().mintFee;
    }

    function _decimals() internal view virtual returns (uint8) {
        return MarketplaceBaseStorage.layout().sokosDecimals;
    }

    function _feeReceipient() internal view virtual returns (address) {
        return MarketplaceBaseStorage.layout().feeReceipient;
    }
}
