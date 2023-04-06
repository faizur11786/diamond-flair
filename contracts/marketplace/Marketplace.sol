// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./base/MarketplaceBaseERC2771.sol";
import {AuctionExtension} from "./extensions/auction/AuctionExtension.sol";

// import "./extensions/supply/ERC20SupplyExtension.sol";
// import "./extensions/mintable/ERC20MintableExtension.sol";
// import "./extensions/burnable/ERC20BurnableExtension.sol";

/**
 * @title Marketplace - with meta-transactions
 * @notice Standard EIP-20 with ability to accept meta transactions (mainly transfer and approve methods).
 *
 * @custom:type eip-2535-facet
 * @custom:category Marketplace
 * @custom:provides-interfaces IMarketplace IMarketplaceBase IAuctionExtension IMarketplaceMintableExtension
 */
contract Marketplace is MarketplaceBaseERC2771, AuctionExtension {
    function _msgSender()
        internal
        view
        virtual
        override(Context, MarketplaceBaseERC2771)
        returns (address)
    {
        return MarketplaceBaseERC2771._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, MarketplaceBaseERC2771)
        returns (bytes calldata)
    {
        return MarketplaceBaseERC2771._msgData();
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(MarketplaceBaseInternal, ERC20SupplyExtension) {
        ERC20SupplyExtension._beforeTokenTransfer(from, to, amount);
    }
}
