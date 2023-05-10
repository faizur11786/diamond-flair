// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {OwnableInternal} from "../../access/ownable/OwnableInternal.sol";

import {FactoryStorage} from "./storage/FactoryStorage.sol";
import {FactoryInternal} from "./FactoryInternal.sol";

/**
 * @title Factory - Admin - Ownable
 * @notice Allows diamond owner to change config of Factory.
 *
 * @custom:type eip-2535-facet
 * @custom:category Factory
 * @custom:peer-dependencies OwnableInternal
 * @custom:provides-interfaces IFactory
 */
contract Factory is FactoryInternal, OwnableInternal {
    function createERC1155Collection(
        string memory name,
        string memory symbol,
        string memory uri,
        address trustedForwarder
    ) external onlyOwner {
        if (_isCollectionExist(name, symbol)) {
            revert ErrDuplicateCollection();
        }
        _createERC1155Collection(name, symbol, uri, _owner(), trustedForwarder);
    }

    // function createERC721Collection(
    //     string memory name,
    //     string memory symbol,
    //     address royaltyReceiver,
    //     uint256 royaltyPercentage,
    //     address trustedForwarder
    // ) external onlyOwner {
    //     if (_isCollectionExist(name, symbol)) {
    //         revert ErrDuplicateCollection();
    //     }
    //     _createERC721Collection(
    //         name,
    //         symbol,
    //         royaltyReceiver,
    //         royaltyPercentage,
    //         _owner(),
    //         trustedForwarder
    //     );
    // }

    function collections()
        external
        view
        returns (FactoryStorage.Collection[] memory)
    {
        return _collections();
    }
}
