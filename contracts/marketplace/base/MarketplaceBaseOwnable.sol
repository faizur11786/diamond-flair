// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {OwnableInternal} from "../../access/ownable/OwnableInternal.sol";

import {MarketplaceBaseStorage} from "./storage/MarketplaceBaseStorage.sol";
import {IMarketplaceBaseOwnable} from "./interfaces/IMarketplaceBaseOwnable.sol";

/**
 * @title ERC20 - Metadata - Admin - Ownable
 * @notice Allows diamond owner to change decimals config and fee config.
 *
 * @custom:type eip-2535-facet
 * @custom:category Marketplace
 * @custom:peer-dependencies OwnableInternal
 * @custom:provides-interfaces IMarketplaceBaseOwnable
 */
contract MarketplaceBaseOwnable is IMarketplaceBaseOwnable, OwnableInternal {
    function setFee(uint16 newFee) external override onlyOwner {
        MarketplaceBaseStorage.Layout storage l = MarketplaceBaseStorage
            .layout();
        l.sokosFee = newFee;
        emit FeeUpdate(newFee);
    }

    function setMintFee(uint16 newMintFee) external override onlyOwner {
        MarketplaceBaseStorage.Layout storage l = MarketplaceBaseStorage
            .layout();
        l.mintFee = newMintFee;
        emit MintFeeUpdate(newMintFee);
    }

    function setDecimals(uint8 newDecimals) external override onlyOwner {
        MarketplaceBaseStorage.Layout storage l = MarketplaceBaseStorage
            .layout();
        l.sokosDecimals = newDecimals;
        emit DecimalsUpdate(newDecimals);
    }

    function setFeeReceipient(address newAddress) external override onlyOwner {
        MarketplaceBaseStorage.Layout storage l = MarketplaceBaseStorage
            .layout();
        l.feeReceipient = payable(newAddress);
        emit FeeReceipientUpdate(newAddress);
    }
}
