// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "../../../metatx/ERC2771ContextInternal.sol";

import "./MarketplaceBase.sol";

abstract contract MarketplaceBaseERC2771 is
    MarketplaceBase,
    ERC2771ContextInternal
{
    function _msgSender()
        internal
        view
        virtual
        override(Context, ERC2771ContextInternal)
        returns (address)
    {
        return ERC2771ContextInternal._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ERC2771ContextInternal)
        returns (bytes calldata)
    {
        return ERC2771ContextInternal._msgData();
    }
}
