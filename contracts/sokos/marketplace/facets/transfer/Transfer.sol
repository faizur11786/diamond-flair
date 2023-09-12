// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ITransfer} from "./interfaces/ITransfer.sol";
import {ReentrancyGuard} from "../../../../security/ReentrancyGuard.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol"; // Step 1: Import the Context contract

contract Transfer is ITransfer, ReentrancyGuard, Context {
    /**
    /// @param _token Token address
    /// @param _to Target Address
    /// @param _from Target Address
    /// @param _id Id of the token type
    /// @param _value Id of the token type
    */
    function transferERC1155(
        IERC1155 _token,
        address _to,
        address _from,
        uint256 _id,
        uint256 _value
    ) public {
        _token.safeTransferFrom(_from, _to, _id, _value, "0x");
    }

    /**
    /// @param _token Token address
    /// @param _to Target Address
    /// @param _from Target Address
    /// @param _id Id of the token type
    */
    function transferERC721(
        IERC721 _token,
        address _to,
        address _from,
        uint256 _id
    ) public {
        _token.safeTransferFrom(_from, _to, _id, "0x");
    }
}
