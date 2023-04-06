// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IMarketplaceBaseOwnable {
    event FeeUpdate(uint16 newFee);
    event MintFeeUpdate(uint16 newMintFee);
    event DecimalsUpdate(uint8 newDecimals);
    event FeeReceipientUpdate(address newAddress);

    function setFee(uint16 newFee) external;

    function setMintFee(uint16 newMintFee) external;

    function setDecimals(uint8 newDecimals) external;

    function setFeeReceipient(address newAddress) external;
}
