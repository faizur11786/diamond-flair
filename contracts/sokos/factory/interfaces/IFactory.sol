// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {FactoryStorage} from "../storage/FactoryStorage.sol";

interface IFactory {
    function collections()
        external
        view
        returns (FactoryStorage.Collection[] memory);
}
