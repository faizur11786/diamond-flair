// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IMarketplaceBaseOwnable {
    event FeeUpdate(uint104 newFee);
    event MintFeeUpdate(uint104 newMintFee);
    event DecimalsUpdate(uint8 newDecimals);
    event FeeReceipientUpdate(address newAddress);
    event PaymentOptionAdded(address token, address feed, uint8 decimals);
    event PaymentOptionRemoved(address token);

    function setFee(uint104 newFee) external;

    function setMintFee(uint104 newMintFee) external;

    function setDecimals(uint8 newDecimals) external;

    function setFeeReceipient(address newAddress) external;

    function addPayableToken(
        address token,
        address feed,
        uint8 decimals
    ) external;

    function removeTokenFeed(address token) external;
}
