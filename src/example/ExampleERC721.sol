// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {OperatorFilterer} from "../OperatorFilterer.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/**
 * @title  ExampleERC721
 * @notice This example contract is configured to use the DefaultOperatorFilterer, which automatically registers the
 *         token and subscribes it to OpenSea's curated filters.
 *         Adding the onlyAllowedOperator modifier to the transferFrom and both safeTransferFrom methods ensures that
 *         the msg.sender (operator) is allowed by the OperatorFilterRegistry.
 */
abstract contract ExampleERC721 is ERC721, OperatorFilterer, Ownable {
    bool public operatorFilteringEnabled;

    constructor() ERC721("Example", "EXAMPLE") {
        _registerForOperatorFiltering();
        operatorFilteringEnabled = true;
    }

    function repeatRegistration() public {
        _registerForOperatorFiltering();
    }

    function setApprovalForAll(address operator, bool approved)
        public
        override
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        override
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId)
        public
        override
        onlyAllowedOperator(from)
    {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "";
    }

    function setOperatorFilteringEnabled(bool value) public onlyOwner {
        operatorFilteringEnabled = value;
    }

    function _operatorFilteringEnabled() internal view virtual override returns (bool) {
        return operatorFilteringEnabled;
    }
}
