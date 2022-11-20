# ClosedSea 🚪

[![NPM][npm-shield]][npm-url]
[![CI][ci-shield]][ci-url]
[![MIT License][license-shield]][license-url]

Gas optimized and flexible version of OpenSea's Mandatory Operator Filterer for royalties.

## Features

- Modifiers can be toggled on / off efficiently.

- Gas optimized. Saves 300+ gas on transfers.

- Keeps your cilents and some marketplaces happy.

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install vectorized/closedsea
```

To install with [**Hardhat**](https://github.com/nomiclabs/hardhat) or [**Truffle**](https://github.com/trufflesuite/truffle):

```sh
npm install closedsea
```

## Contracts

```ml
src
├─ OperatorFilterer.sol — "Operator Filterer for regular and upgradeable contracts"
└─ example
   ├─ ExampleERC721A.sol — "ERC721A example with demonstration of togglability"
   ├─ ExampleERC721.sol — "ERC721 example with demonstration of togglability"
   ├─ ExampleERC1155.sol — "ERC1155 example"
   └─ upgradeable
      ├─ ExampleERC721AUpgradeable.sol — "ERC721A upgradeable example"
      ├─ ExampleERC721Upgradeable.sol — "ERC721 upgradeable example"
      └─ ExampleERC1155Upgradeable.sol — "ERC1155 upgradeable example"
``` 

## Examples

| Type | Contract |
|---|---|
| ERC721A | [`src/example/ExampleERC721A.sol`](./src/example/ExampleERC721A.sol) |
| ERC721 | [`src/example/ExampleERC721.sol`](./src/example/ExampleERC721.sol) |
| ERC1155 | [`src/example/ExampleERC1155.sol`](./src/example/ExampleERC1155.sol) |
| ERC721AUpgradeable | [`src/example/upgradeable/ExampleERC721AUpgradeable.sol`](./src/example/upgradeable/ExampleERC721AUpgradeable.sol) |
| ERC721Upgradeable | [`src/example/upgradeable/ExampleERC721Upgradeable.sol`](./src/example/upgradeable/ExampleERC721Upgradeable.sol) |
| ERC1155Upgradeable | [`src/example/upgradeable/ExampleERC1155Upgradeable.sol`](./src/example/upgradeable/ExampleERC1155Upgradeable.sol) |

## API

### `_registerForOperatorFiltering`
```solidity 
function _registerForOperatorFiltering(
    address subscriptionOrRegistrantToCopy, 
    bool subscribe
) internal virtual
````
Registration function that can be called in an initializer, anywhere.  

Can be called repeatedly without issues.

To subscribe to the [default OpenSea curated block list](https://github.com/ProjectOpenSea/operator-filter-registry/#deployments), simply use `_registerForOperatorFiltering()`, without arguments.

### `onlyAllowedOperator`
```solidity
modifier onlyAllowedOperator(address from) virtual
```  
Modifier to guard a function and revert if `from` is a blocked operator.  

### `onlyAllowedOperatorApproval`
```solidity
modifier onlyAllowedOperatorApproval(address operator) virtual
```  
Modifier to guard a function from approving a blocked operator.  

### `_operatorFilteringEnabled`
```solidity
function _operatorFilteringEnabled() internal view virtual returns (bool)
```  
For deriving contracts to override, so that operator filtering can be turned on / off.

Returns true by default.

### `_isPriorityOperator`
```solidity
function _isPriorityOperator(address operator) internal view virtual returns (bool)
```  
For deriving contracts to override, so that preferred marketplaces can skip operator filtering, helping users save gas.

Returns false for all inputs by default.

## Safety

We have verified with OpenSea engineers that ClosedSea is fully compatible with their royalties enforcement system, as of Nov 18th 2022.

Nevertheless, this codebase is provided on an "as is" and "as available" basis.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

## Acknowledgements

This repository is inspired by and directly modified from:

- [operator-filter-registry](https://github.com/ProjectOpenSea/operator-filter-registry)

[npm-shield]: https://img.shields.io/npm/v/closedsea.svg
[npm-url]: https://www.npmjs.com/package/closedsea

[ci-shield]: https://img.shields.io/github/workflow/status/vectorized/closedsea/ci?label=build
[ci-url]: https://github.com/vectorized/closedsea/actions/workflows/ci.yml

[license-shield]: https://img.shields.io/badge/License-MIT-green.svg
[license-url]: https://github.com/vectorized/closedsea/blob/main/LICENSE.txt
