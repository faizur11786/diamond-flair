// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IFactoryInternal} from "./interfaces/IFactoryInternal.sol";
import {IFactoryExtension} from "./interfaces/IFactoryExtension.sol";

import {MarketplaceBaseInternal} from "../../base/MarketplaceBaseInternal.sol";
import {FactoryStorage} from "./storage/FactoryStorage.sol";
import {FactoryInternal} from "./FactoryInternal.sol";

abstract contract FactoryExtension is IFactoryExtension, FactoryInternal {
    using FactoryStorage for FactoryStorage.Layout;
}
