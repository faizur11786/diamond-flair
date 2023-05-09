// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Strings.sol";

import {OwnableInternal} from "../../../../access/ownable/OwnableInternal.sol";

import {ERC20MetadataInternal} from "./ERC20MetadataInternal.sol";
import {ERC20MetadataStorage} from "./storage/ERC20MetadataStorage.sol";
import {IERC20MetadataAdmin} from "./interfaces/IERC20MetadataAdmin.sol";

/**
 * @title ERC20 - Metadata - Admin - Ownable
 * @notice Allows diamond owner to change decimals config or freeze it forever.
 *
 * @custom:type eip-2535-facet
 * @custom:category Tokens
 * @custom:peer-dependencies IERC20Metadata
 * @custom:provides-interfaces IERC20MetadataAdmin
 */
contract ERC20MetadataOwnable is
    IERC20MetadataAdmin,
    ERC20MetadataInternal,
    OwnableInternal
{
    function setDecimals(uint8 newDecimals) external override onlyOwner {
        ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();
        require(!l.decimalsLocked, "ERC20MetadataOwnable: decimals locked");
        l.decimals = newDecimals;
    }

    function lockDecimals() external override onlyOwner {
        ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();
        l.decimalsLocked = true;
    }

    function setName(string memory newName) external override onlyOwner {
        ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();
        require(
            !l.nameAndSymbolLocked,
            "ERC20MetadataOwnable: name and symbol locked"
        );
        l.name = newName;
    }

    function setSymbol(string memory newSymbol) external override onlyOwner {
        ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();
        require(
            !l.nameAndSymbolLocked,
            "ERC20MetadataOwnable: name and symbol locked"
        );
        l.symbol = newSymbol;
    }

    function lockNameAndSymbol() external override onlyOwner {
        ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();
        l.nameAndSymbolLocked = true;
    }
}
