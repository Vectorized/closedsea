// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC721AUpgradeable, ERC721AUpgradeable} from "erc721a-upgradeable/ERC721AUpgradeable.sol";
import {ERC721AQueryableUpgradeable} from
    "erc721a-upgradeable/extensions/ERC721AQueryableUpgradeable.sol";
import {ERC721ABurnableUpgradeable} from
    "erc721a-upgradeable/extensions/ERC721ABurnableUpgradeable.sol";
import {OperatorFilterer} from "../../OperatorFilterer.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {
    IERC2981Upgradeable,
    ERC2981Upgradeable
} from "openzeppelin-contracts-upgradeable/token/common/ERC2981Upgradeable.sol";

/**
 * @title  ExampleERC721AUpgradeable
 * @notice This example contract is configured to use the DefaultOperatorFilterer, which automatically registers the
 *         token and subscribes it to OpenSea's curated filters.
 *         Adding the onlyAllowedOperator modifier to the transferFrom and both safeTransferFrom methods ensures that
 *         the msg.sender (operator) is allowed by the OperatorFilterRegistry.
 */
abstract contract ExampleERC721AUpgradeable is
    ERC721AQueryableUpgradeable,
    ERC721ABurnableUpgradeable,
    OperatorFilterer,
    OwnableUpgradeable,
    ERC2981Upgradeable
{
    bool public operatorFilteringEnabled;

    function initialize() public initializer initializerERC721A {
        __ERC721A_init("Example", "EXAMPLE");
        __Ownable_init();
        __ERC2981_init();

        _registerForOperatorFiltering();
        operatorFilteringEnabled = true;

        // Set royalty receiver to the contract creator,
        // at 5% (default denominator is 10000).
        _setDefaultRoyalty(msg.sender, 500);
    }

    function setApprovalForAll(address operator, bool approved)
        public
        override (IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        payable
        override (IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId)
        public
        payable
        override (IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperator(from)
    {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId)
        public
        payable
        override (IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        payable
        override (IERC721AUpgradeable, ERC721AUpgradeable)
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (IERC721AUpgradeable, ERC721AUpgradeable, ERC2981Upgradeable)
        returns (bool)
    {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return ERC721AUpgradeable.supportsInterface(interfaceId)
            || ERC2981Upgradeable.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setOperatorFilteringEnabled(bool value) public onlyOwner {
        operatorFilteringEnabled = value;
    }

    function _operatorFilteringEnabled() internal view override returns (bool) {
        return operatorFilteringEnabled;
    }

    function _isPriorityOperator(address operator) internal pure override returns (bool) {
        // OpenSea Seaport Conduit:
        // https://etherscan.io/address/0x1E0049783F008A0085193E00003D00cd54003c71
        // https://goerli.etherscan.io/address/0x1E0049783F008A0085193E00003D00cd54003c71
        return operator == address(0x1E0049783F008A0085193E00003D00cd54003c71);
    }
}
