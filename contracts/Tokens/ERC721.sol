// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC2981, IERC165 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";

import { ERC721URIStorage, ERC721, Context } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import { AccessControl, Strings } from "@openzeppelin/contracts/access/AccessControl.sol";
import { MetaContext } from "./common/MetaContext.sol";

contract SokosERC721 is
    IERC2981,
    MetaContext,
    ERC721URIStorage,
    ERC721Burnable,
    ERC721Enumerable,
    AccessControl
{
    using Counters for Counters.Counter;
    Counters.Counter public tokenCounter;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _royaltyPercentage; // Royalty percentage, multiplied by 1000 (e.g. 5000 = 5%)
    address private _royaltyReceiver; // Royalty receiver
    string public contractUri;

    constructor(
        string memory name,
        string memory symbol,
        address royaltyReceiver,
        uint256 royaltyPercentage,
        address owner,
        address trustedForwarder
    ) ERC721(name, symbol) MetaContext(trustedForwarder) {
        _royaltyReceiver = royaltyReceiver;
        _royaltyPercentage = royaltyPercentage;
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _setupRole(ADMIN_ROLE, owner);
        _setupRole(MINTER_ROLE, owner);
    }

    modifier only(bytes32 role) {
        if (!hasRole(role, _msgSender())) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(_msgSender()),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
        _;
    }

    function _msgSender()
        internal
        view
        override(Context, MetaContext)
        returns (address sender)
    {
        return MetaContext._msgSender();
    }

    function _msgData()
        internal
        view
        override(Context, MetaContext)
        returns (bytes calldata)
    {
        return MetaContext._msgData();
    }

    function setContractURI(string memory _uri) external only(ADMIN_ROLE) {
        contractUri = _uri;
    }

    function mint(
        address owner,
        string memory uri
    ) external only(MINTER_ROLE) returns (uint256) {
        tokenCounter.increment();

        uint256 newItemId = tokenCounter.current();
        _safeMint(owner, newItemId);
        _setTokenURI(newItemId, uri);

        return newItemId;
    }

    function setRoyalties(
         address payable royaltyReceiver,
        uint104 royaltyPercentage
    ) external only(ADMIN_ROLE) {
        require(
            royaltyPercentage <= 10000,
            "SokosToken: Royalty percentage must be less than or equal to 100%"
        );
        _royaltyPercentage = royaltyPercentage;
        _royaltyReceiver = royaltyReceiver;
    }

    function royaltyInfo(
        uint256 royaltyPercentage,
        uint256 value
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        receiver = _royaltyReceiver;
        royaltyAmount = (value * royaltyPercentage) / 100000; // Calculate royalty as a percentage of sale value
    }

    function getRoyaltyPercentage() external view returns (uint256) {
        return _royaltyPercentage;
    }

    function getRoyaltyReceiver() public view returns (address) {
        return _royaltyReceiver;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, IERC165, ERC721Enumerable, AccessControl, ERC721URIStorage)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721URIStorage, ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function setTrustedForwarder(
        address trustedForwarder
    ) external only(ADMIN_ROLE) {
        _trustedForwarder = trustedForwarder;
    }

    function withdrawFunds(address token) external only(ADMIN_ROLE) {
        require(
            IERC20(token).balanceOf(address(this)) > 0,
            "No funds to withdraw"
        );
        IERC20(token).transfer(
            _msgSender(),
            IERC20(token).balanceOf(address(this))
        );
    }

    function withdraw() external only(ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        payable(_msgSender()).transfer(balance);
    }
}
