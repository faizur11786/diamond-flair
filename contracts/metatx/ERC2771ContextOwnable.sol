// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "../access/ownable/OwnableInternal.sol";
import "./ERC2771ContextStorage.sol";
import "./IERC2771ContextOwnable.sol";

/**
 * @title ERC2771 Context - Admin - Ownable
 * @notice Controls trusted forwarder used to accept meta transactions according to EIP-2771.
 *
 * @custom:type eip-2535-facet
 * @custom:category Meta Transactions
 * @custom:provides-interfaces IERC2771ContextOwnable
 */
contract ERC2771ContextOwnable is IERC2771ContextOwnable, OwnableInternal {
    function setTrustedForwarder(address trustedForwarder) public onlyOwner {
        ERC2771ContextStorage.layout().trustedForwarder = trustedForwarder;
    }
}
