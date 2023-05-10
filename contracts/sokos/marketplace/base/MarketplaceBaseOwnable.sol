// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {OwnableInternal} from "../../../access/ownable/OwnableInternal.sol";

import {MarketplaceBaseStorage} from "./storage/MarketplaceBaseStorage.sol";
import {IMarketplaceBaseOwnable} from "./interfaces/IMarketplaceBaseOwnable.sol";

/**
 * @title MarketplaceBaseOwnable - Admin - Ownable
 * @notice Allows diamond owner to change config of marketplace.
 *
 * @custom:type eip-2535-facet
 * @custom:category Marketplace
 * @custom:peer-dependencies OwnableInternal
 * @custom:provides-interfaces IMarketplaceBaseOwnable
 */
contract MarketplaceBaseOwnable is IMarketplaceBaseOwnable, OwnableInternal {
    function setFee(uint104 newFee) external override onlyOwner {
        MarketplaceBaseStorage.Layout storage l = MarketplaceBaseStorage
            .layout();
        l.sokosFee = newFee;
        emit FeeUpdate(newFee);
    }

    function setMintFee(uint104 newMintFee) external override onlyOwner {
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

    function addPayableToken(
        address newToken,
        address feed,
        uint8 decimals
    ) external override onlyOwner {
        MarketplaceBaseStorage.Layout storage l = MarketplaceBaseStorage
            .layout();
        require(newToken != address(0), "invalid token");

        MarketplaceBaseStorage.TokenFeed memory token = l.payableToken[
            newToken
        ];
        require(token.feed == address(0), "already payable token");
        token.feed = feed;
        token.decimals = decimals;
        emit PaymentOptionAdded(newToken, feed, decimals);
    }

    function removeTokenFeed(address token) external override onlyOwner {
        require(token != address(0), "invalid token");

        MarketplaceBaseStorage.Layout storage l = MarketplaceBaseStorage
            .layout();

        delete l.payableToken[token];
        emit PaymentOptionRemoved(token);
    }
}
