// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20Metadata {
    /**
     * @notice return token decimals, generally used only for display purposes
     * @return token decimals
     */
    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function nameAndSymbolLocked() external view returns (bool);

    function decimalsLocked() external view returns (bool);
}
