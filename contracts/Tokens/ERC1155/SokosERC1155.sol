// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1155MetadataURI} from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

import {ERC1155, ERC1155URIStorage, Context, IERC165} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {MetaContext} from "../common/MetaContext.sol";
import {RoyaltiesV2Impl, LibPart} from "./RoyaltiesV2/RoyaltiesV2.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {AccessControl, Strings} from "@openzeppelin/contracts/access/AccessControl.sol";

contract SokosERC1155 is
    IERC1155MetadataURI,
    MetaContext,
    ERC1155URIStorage,
    ERC1155Burnable,
    ERC1155Supply,
    RoyaltiesV2Impl,
    AccessControl
{
    using Counters for Counters.Counter;
    Counters.Counter public tokenCounter;

    bytes4 internal constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    bytes4 internal constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public contractUri;
    string public name;
    string public symbol;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        address owner,
        address trustedForwarder
    ) ERC1155("") MetaContext(trustedForwarder) {
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _setupRole(ADMIN_ROLE, owner);
        _setupRole(MINTER_ROLE, owner);
        name = tokenName;
        symbol = tokenSymbol;
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

    function setName(string memory _name) external only(ADMIN_ROLE) {
        name = _name;
    }

    function setSymbol(string memory _symbol) external only(ADMIN_ROLE) {
        symbol = _symbol;
    }

    function setContractURI(string memory _uri) external only(ADMIN_ROLE) {
        contractUri = _uri;
    }

    function setRoyalties(
        uint256 tokenId,
        address payable royaltyReceiver,
        uint104 royaltyPercentage
    ) public only(ADMIN_ROLE) {
        require(exists(tokenId), "nonexistent token");
        require(
            royaltyPercentage < 10000,
            "Royalty percentage must be less than or equal to 100%"
        );
        LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        _royalties[0].value = royaltyPercentage;
        _royalties[0].account = royaltyReceiver;
        _saveRoyalties(tokenId, _royalties);
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        LibPart.Part[] memory _royalties = royalties[tokenId];
        if (_royalties.length > 0) {
            return (
                _royalties[0].account,
                (salePrice * _royalties[0].value) / 10000
            );
        }
        return (address(0), 0);
    }

    function mint(
        address to,
        uint256 amount,
        bytes memory tokenURI,
        uint104 royaltyPercentage,
        address payable royaltyReceiver
    ) public only(MINTER_ROLE) {
        uint256 _id = tokenCounter.current();
        tokenCounter.increment();
        _mint(to, _id, amount, tokenURI);
        _setURI(_id, string(tokenURI));
        if (royaltyPercentage > 0) {
            setRoyalties(_id, royaltyReceiver, royaltyPercentage);
        }
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public only(MINTER_ROLE) {
        require(ids.length == amounts.length, "Invalid length");
        for (uint i = 0; i < ids.length; i++) {
            if (!exists(ids[i])) {
                tokenCounter.increment();
            }
        }
        _mintBatch(to, ids, amounts, data);
    }

    function setTokenURI(
        uint256 tokenId,
        string memory tokenURI
    ) public only(MINTER_ROLE) {
        require(exists(tokenId), "URI set for nonexistent token");
        _setURI(tokenId, tokenURI);
    }

    function setTokenURIBatch(
        uint256[] memory tokenId,
        string[] memory tokenURI
    ) public only(MINTER_ROLE) {
        require(tokenId.length == tokenURI.length, "Invalid length");
        for (uint i = 0; i < tokenId.length; i++) {
            _setURI(tokenId[i], tokenURI[i]);
        }
    }

    function setCollectionURI(string memory newuri) public only(ADMIN_ROLE) {
        _setURI(newuri);
    }

    function uri(
        uint256 id
    )
        public
        view
        virtual
        override(ERC1155, ERC1155URIStorage, IERC1155MetadataURI)
        returns (string memory)
    {
        require(exists(id), "URI query for nonexistent token");
        return super.uri(id);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function setTrustedForwarder(
        address trustedForwarder
    ) external only(ADMIN_ROLE) {
        _trustedForwarder = trustedForwarder;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC1155, IERC165, AccessControl)
        returns (bool)
    {
        return
            interfaceId == _INTERFACE_ID_ERC2981 ||
            interfaceId == _INTERFACE_ID_ROYALTIES ||
            super.supportsInterface(interfaceId);
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
