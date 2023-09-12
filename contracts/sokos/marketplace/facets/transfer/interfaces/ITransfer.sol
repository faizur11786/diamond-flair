// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ITransfer {
    function transferERC1155(
        IERC1155 _token,
        address _to,
        address _from,
        uint256 _id,
        uint256 _value
    ) external;

    function transferERC721(
        IERC721 _token,
        address _to,
        address _from,
        uint256 _id
    ) external;
}
