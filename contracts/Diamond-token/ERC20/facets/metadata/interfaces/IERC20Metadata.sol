// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20Metadata {
    /**
     * @notice return token decimals, generally used only for display purposes
     * @return token decimals
     */
    function decimals() external view returns (uint8);

    /**
     * @notice return token name, generally used only for display purposes
     * @return token name
     */
    function name() external view returns (string memory);

    /**
     * @notice return token symbol, generally used only for display purposes
     * @return token symbol
     */
    function symbol() external view returns (string memory);

    /**
     * @notice return name and Symbol Locked
     * @return boolean name and symbol Locked status
     */
    function nameAndSymbolLocked() external view returns (bool);

    /**
     * @notice return decimals Locked
     * @return boolean decimals
     */
    function decimalsLocked() external view returns (bool);
}
