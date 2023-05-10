// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {OwnableInternal} from "../../access/ownable/OwnableInternal.sol";

import {FactoryStorage} from "./storage/FactoryStorage.sol";
import {FactoryInternal} from "./FactoryInternal.sol";

import {IFactoryOwnable} from "./interfaces/IFactoryOwnable.sol";
import {IFactory} from "./interfaces/IFactory.sol";

/**
 * @title FactoryOwnable - Admin - Ownable
 * @notice Allows diamond owner to change config of Factory.
 *
 * @custom:type eip-2535-facet
 * @custom:category Factory
 * @custom:peer-dependencies OwnableInternal
 * @custom:provides-interfaces IFactoryOwnable
 */
contract FactoryOwnable is IFactoryOwnable, FactoryInternal, OwnableInternal {
    function createCollection(
        string memory name,
        string memory symbol,
        string memory uri,
        address royaltyReceiver,
        uint256 royaltyPercentage,
        bool isERC1155,
        address trustedForwarder
    ) external override onlyOwner {
        if (_isCollectionExist(name, symbol)) {
            revert ErrDuplicateCollection();
        }

        bool success;

        if (isERC1155) {
            success = _createERC1155Collection(
                name,
                symbol,
                uri,
                _owner(),
                trustedForwarder
            );
        } else {
            success = _createERC721Collection(
                name,
                symbol,
                royaltyReceiver,
                royaltyPercentage,
                _owner(),
                trustedForwarder
            );
        }

        if (!success) {
            revert ErrCreateCollectionFailed();
        }
    }

    function collections()
        external
        view
        returns (FactoryStorage.Collection[] memory)
    {
        return _collections();
    }
}
