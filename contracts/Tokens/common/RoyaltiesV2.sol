// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

library LibPart {
    struct Part {
        address payable account;
        uint104 value;
    }
    bytes4 public constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;
}

interface IRoyaltiesV2 {
    event RoyaltiesSet(uint256 tokenId, LibPart.Part royalties);

    function getRaribleV2Royalties(
        uint256 id
    ) external view returns (LibPart.Part memory);
}

abstract contract AbstractRoyalties {
    mapping(uint256 => LibPart.Part) internal royalties;

    function _onRoyaltiesSet(
        uint256 id,
        LibPart.Part memory _royalties
    ) internal virtual;
}

contract RoyaltiesV2Impl is AbstractRoyalties, IRoyaltiesV2 {
    function getRaribleV2Royalties(
        uint256 id
    ) external view override returns (LibPart.Part memory) {
        return royalties[id];
    }

    function _onRoyaltiesSet(
        uint256 id,
        LibPart.Part memory _royalties
    ) internal override {
        emit RoyaltiesSet(id, _royalties);
    }
}
