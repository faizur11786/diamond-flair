// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IMarketplaceBaseInternal} from "./IMarketplaceBaseInternal.sol";
import {IMarketplaceBaseOwnable} from "./IMarketplaceBaseOwnable.sol";
import {MarketplaceBaseStorage} from "../storage/MarketplaceBaseStorage.sol";

/**
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IMarketplaceBase is IMarketplaceBaseInternal {
    function fee() external view returns (uint16);

    function mintFee() external view returns (uint16);

    function decimals() external view returns (uint8);

    function feeReceipient() external view returns (address);

    function getPayableTokens(
        address token
    ) external view returns (MarketplaceBaseStorage.TokenFeed memory);
}
