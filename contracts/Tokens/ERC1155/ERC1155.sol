// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC2981, IERC165} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {IERC1155MetadataURI} from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

import {ERC1155, ERC1155URIStorage, Context} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RoyaltiesV2Impl, LibPart} from "./RoyaltiesV2/RoyaltiesV2.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

// import "@openzeppelin/contracts/access/AccessControl.sol";

contract SokosERC1155 is
    IERC1155MetadataURI,
    ERC2771Context,
    ERC1155URIStorage,
    ERC1155Burnable,
    ERC1155Supply,
    Ownable,
    RoyaltiesV2Impl
{
    using Counters for Counters.Counter;
    Counters.Counter public tokenCounter;
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    bytes4 private constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;

    // bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(
        address trustedForwarder
    ) ERC1155("") ERC2771Context(trustedForwarder) {}

    function _msgSender()
        internal
        view
        override(Context, ERC2771Context)
        returns (address sender)
    {
        return ERC2771Context._msgSender();
    }

    function _msgData()
        internal
        view
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    function setRoyalties(
        uint256 _tokenId,
        address payable _royaltyReceiver,
        uint104 _royaltyPercentage
    ) public onlyOwner {
        require(
            _royaltyPercentage < 10000,
            "Royalty percentage must be less than or equal to 100%"
        );
        LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        _royalties[0].value = _royaltyPercentage;
        _royalties[0].account = _royaltyReceiver;
        _saveRoyalties(_tokenId, _royalties);
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        LibPart.Part[] memory _royalties = royalties[_tokenId];
        if (_royalties.length > 0) {
            return (
                _royalties[0].account,
                (_salePrice * _royalties[0].value) / 10000
            );
        }
        return (address(0), 0);
    }

    function stringToBytes(
        string memory _string
    ) public pure returns (bytes memory) {
        return bytes(_string);
    }

    function mint(
        uint256 amount,
        bytes memory tokenURI,
        uint104 _royaltyPercentage,
        address payable _royaltyReceiver
    ) public onlyOwner {
        uint256 _id = tokenCounter.current();
        tokenCounter.increment();
        _mint(_msgSender(), _id, amount, tokenURI);
        _setURI(_id, string(tokenURI));
        if (_royaltyPercentage > 0) {
            setRoyalties(_id, _royaltyReceiver, _royaltyPercentage);
        }
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
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
    ) public onlyOwner {
        _setURI(tokenId, tokenURI);
    }

    function setTokenURIBatch(
        uint256[] memory tokenId,
        string[] memory tokenURI
    ) public onlyOwner {
        require(tokenId.length == tokenURI.length, "Invalid length");
        for (uint i = 0; i < tokenId.length; i++) {
            _setURI(tokenId[i], tokenURI[i]);
        }
    }

    function setCollectionURI(string memory newuri) public onlyOwner {
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

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, IERC165) returns (bool) {
        return
            interfaceId == _INTERFACE_ID_ERC2981 ||
            interfaceId == _INTERFACE_ID_ROYALTIES ||
            super.supportsInterface(interfaceId);
    }

    function withdrawFunds(address token) external onlyOwner {
        require(
            IERC20(token).balanceOf(address(this)) > 0,
            "No funds to withdraw"
        );
        IERC20(token).transfer(
            _msgSender(),
            IERC20(token).balanceOf(address(this))
        );
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_msgSender()).transfer(balance);
    }
}
