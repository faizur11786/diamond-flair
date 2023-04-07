// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface ISokosNFT {
    function getRoyaltyFee() external view returns (uint256);

    function getRoyaltyRecipient() external view returns (address);
}
