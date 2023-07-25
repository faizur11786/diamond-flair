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
import { RoyaltiesV2Impl, LibPart } from "./common/RoyaltiesV2.sol";

contract SokosERC721 is
    IERC2981,
    MetaContext,
    ERC721URIStorage,
    ERC721Burnable,
    ERC721Enumerable,
    RoyaltiesV2Impl,
    AccessControl
{
    using Counters for Counters.Counter;
    Counters.Counter public tokenCounter;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public contractUri;

    event MintBatch(address[] indexed tos, uint256[] ids);

    constructor(
        string memory name,
        string memory symbol,
        address owner,
        address trustedForwarder
    ) ERC721(name, symbol) MetaContext(trustedForwarder) {
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
        address to,
        string memory uri,
        uint104 royaltyPercentage,
        address payable royaltyReceiver
    ) public only(MINTER_ROLE) returns (uint256) {
        tokenCounter.increment();
        uint256 newItemId = tokenCounter.current();
        _safeMint(to, newItemId);
        _setTokenURI(newItemId, uri);

        if (royaltyReceiver != address(0) && royaltyPercentage > 0) {
            LibPart.Part memory royalty = LibPart.Part({
                value: royaltyPercentage,
                account: royaltyReceiver
            });
            royalties[newItemId] = royalty;
            _onRoyaltiesSet(newItemId, royalty);
        }
        return newItemId;
    }

    function mintBatch(
        address[] memory tos,
        string[] memory uris,
        uint104[] memory royaltyPercentages,
        address[] memory royaltyReceivers
    ) public only(MINTER_ROLE) {
        require(
            tos.length == uris.length &&
                royaltyPercentages.length == royaltyReceivers.length,
            "Invalid length"
        );
        uint256[] memory ids = new uint256[](tos.length);
        for (uint i = 0; i < tos.length; i++) {
            address to = tos[i];
            string memory uri = uris[i];
            uint104 royaltyPercentage = royaltyPercentages[i];
            address royaltyReceiver = royaltyReceivers[i];
            ids[i] = mint(to, uri, royaltyPercentage, payable(royaltyReceiver));
        }
        emit MintBatch(tos, ids);
    }

    function setRoyalties(
        uint256 tokenId,
        address payable royaltyReceiver,
        uint104 royaltyPercentage
    ) public only(ADMIN_ROLE) {
        require(
            royaltyPercentage < 10000,
            "Royalty percentage must be less than or equal to 100%"
        );
        require(_exists(tokenId), "nonexistent token");
        LibPart.Part memory royalty = LibPart.Part({
            value: royaltyPercentage,
            account: royaltyReceiver
        });
        royalties[tokenId] = royalty;
        _onRoyaltiesSet(tokenId, royalty);
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        LibPart.Part memory _royalties = royalties[tokenId];
        if (_royalties.account != address(0)) {
            return (_royalties.account, (salePrice * _royalties.value) / 10000);
        }
        return (address(0), 0);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            ERC721,
            IERC165,
            ERC721Enumerable,
            AccessControl,
            ERC721URIStorage
        )
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
