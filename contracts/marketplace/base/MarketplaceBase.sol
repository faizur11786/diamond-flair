// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IMarketplaceBase} from "./interfaces/IMarketplaceBase.sol";
import {MarketplaceBaseInternal} from "./MarketplaceBaseInternal.sol";
import {MarketplaceBaseStorage} from "./storage/MarketplaceBaseStorage.sol";

/**
 * @title Base ERC20 implementation, excluding optional extensions
 */
abstract contract MarketplaceBase is MarketplaceBaseInternal, IMarketplaceBase {
    function fee() external view returns (uint104) {
        return _fee();
    }

    function mintFee() external view returns (uint104) {
        return _mintFee();
    }

    function decimals() external view returns (uint8) {
        return _decimals();
    }

    function feeReceipient() external view returns (address) {
        return _feeReceipient();
    }

    function getPayableTokens(
        address token
    ) external view returns (MarketplaceBaseStorage.TokenFeed memory) {
        return _getPayableToken(token);
    }
}
