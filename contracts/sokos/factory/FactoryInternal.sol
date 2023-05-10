// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IFactoryInternal} from "./interfaces/IFactoryInternal.sol";

import {FactoryStorage} from "./storage/FactoryStorage.sol";

import {SokosERC721} from "../../Tokens/ERC721.sol";
import {SokosERC1155} from "../../Tokens/ERC1155/SokosERC1155.sol";

/**
 * @title Factory internal functions, excluding optional extensions
 */
abstract contract FactoryInternal is Context, IFactoryInternal {
    using FactoryStorage for FactoryStorage.Layout;

    function _collections()
        internal
        view
        virtual
        returns (FactoryStorage.Collection[] memory)
    {
        return FactoryStorage.layout().collections;
    }

    function _createERC1155Collection(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _owner,
        address _trustedForwarder
    ) internal returns (bool) {
        SokosERC1155 token = new SokosERC1155(_owner, _trustedForwarder);
        _addCollection(_name, _symbol, _uri, address(token), true);
        return true;
    }

    function _createERC721Collection(
        string memory _name,
        string memory _symbol,
        address _royaltyReceiver,
        uint256 _royaltyPercentage,
        address _owner,
        address _trustedForwarder
    ) internal returns (bool) {
        SokosERC721 token = new SokosERC721(
            _name,
            _symbol,
            _royaltyReceiver,
            _royaltyPercentage,
            _owner,
            _trustedForwarder
        );
        _addCollection(_name, _symbol, string(""), address(token), false);
        return true;
    }

    function _isCollectionExist(
        string memory _name,
        string memory _symbol
    ) internal view returns (bool) {
        FactoryStorage.Collection[] storage collections = FactoryStorage
            .layout()
            .collections;

        for (uint i = 0; i < collections.length; i++) {
            FactoryStorage.Collection storage collection = collections[i];
            if (
                keccak256(abi.encodePacked(collection.name)) ==
                keccak256(abi.encodePacked(_name)) &&
                keccak256(abi.encodePacked(collection.symbol)) ==
                keccak256(abi.encodePacked(_symbol))
            ) {
                return true;
            }
        }
        return false;
    }

    function _addCollection(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _tokenAddress,
        bool _isERC1155
    ) private {
        FactoryStorage.Collection[] storage collections = FactoryStorage
            .layout()
            .collections;

        collections.push(
            FactoryStorage.Collection({
                name: _name,
                symbol: _symbol,
                uri: _uri,
                tokenAddress: _tokenAddress,
                isERC1155: _isERC1155
            })
        );
        emit AddCollection(_tokenAddress, _name, _symbol, _isERC1155);
    }
}
