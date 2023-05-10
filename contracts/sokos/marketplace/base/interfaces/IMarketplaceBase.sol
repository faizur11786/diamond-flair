// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IMarketplaceBaseInternal} from "./IMarketplaceBaseInternal.sol";
import {IMarketplaceBaseOwnable} from "./IMarketplaceBaseOwnable.sol";
import {MarketplaceBaseStorage} from "../storage/MarketplaceBaseStorage.sol";

interface IMarketplaceBase is IMarketplaceBaseInternal {
    function fee() external view returns (uint104);

    function mintFee() external view returns (uint104);

    function decimals() external view returns (uint8);

    function feeReceipient() external view returns (address);

    function getPayableTokens(
        address token
    ) external view returns (MarketplaceBaseStorage.TokenFeed memory);
}
