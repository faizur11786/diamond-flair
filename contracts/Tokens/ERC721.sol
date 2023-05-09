// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC2981, IERC165} from "@openzeppelin/contracts/interfaces/IERC2981.sol";

import {ERC721URIStorage, ERC721, Context} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SokosERC721 is
    IERC2981,
    ERC2771Context,
    ERC721URIStorage,
    ERC721Burnable,
    ERC721Enumerable,
    Ownable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    uint256 private _royaltyPercentage; // Royalty percentage, multiplied by 1000 (e.g. 5000 = 5%)
    address private _royaltyReceiver; // Royalty receiver

    constructor(
        string memory name,
        string memory symbol,
        address royaltyReceiver,
        address trustedForwarder
    ) ERC721(name, symbol) ERC2771Context(trustedForwarder) {
        _royaltyReceiver = royaltyReceiver;
    }

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

    function mint(address owner, string memory uri) external returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(owner, newItemId);
        _setTokenURI(newItemId, uri);

        return newItemId;
    }

    function royaltyInfo(
        uint256 royaltyPercentage,
        uint256 value
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        receiver = _royaltyReceiver;
        royaltyAmount = (value * royaltyPercentage) / 100000; // Calculate royalty as a percentage of sale value
    }

    function setRoyaltyPercentage(uint256 percentage) external onlyOwner {
        require(
            percentage <= 10000,
            "MyToken: Royalty percentage must be less than or equal to 100%"
        );
        _royaltyPercentage = percentage;
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
        override(ERC721, IERC165, ERC721Enumerable)
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
