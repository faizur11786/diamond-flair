// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IFactoryInternal} from "./interfaces/IFactoryInternal.sol";

import {OwnableInternal} from "../../../access/ownable/OwnableInternal.sol";
import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";
import {FactoryStorage} from "./storage/FactoryStorage.sol";

abstract contract FactoryInternal is
    OwnableInternal,
    IFactoryInternal,
    MarketplaceBaseInternal
{
    using FactoryStorage for FactoryStorage.Layout;
}
