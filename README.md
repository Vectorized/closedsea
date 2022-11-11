# ClosedSea 🚪

[![NPM][npm-shield]][npm-url]
[![CI][ci-shield]][ci-url]
[![MIT License][license-shield]][license-url]

Gas optimized and flexible version of OpenSea's Mandatory Operator Filterer for royalties.

## Features

- `modifier onlyAllowedOperator(address from, bool filterEnabled)`  
   modifier that allows conditional toggling of the filter.  

   You can passed in a bool extracted from a packed variable for `filterEnabled`.

- `_registerForOperatorFiltering(address subscriptionOrRegistrantToCopy, bool subscribe)`

   Registration function that can be called in an initializer, anywhere.  

   Can be called repeatedly without issues.

- `_registerForOperatorFiltering()` 

   Registration function similar to above. Uses OpenSea's default block list. 

- Gas optimized. Saves 300+ gas on transfers.

- Keeps your cilents and some marketplaces happy.

## Example

See `src/example/ExampleERC721.sol`.

## Contracts

```ml
src
├─ OperatorFilterer.sol — "Operator Filterer that fits regular and upgradeable contracts"
└─ example
   ├─ ExampleERC1155.sol — "ERC1155 example"
   ├─ ExampleERC721.sol — "ERC721 example with demonstration of togglability"
   └─ upgradeable
      ├─ ExampleERC1155Upgradeable.sol — "ERC1155 upgradeable example"
      └─ ExampleERC721Upgradeable.sol — "ERC721 upgradeable example"
```

## Safety

This is **experimental software** and is provided on an "as is" and "as available" basis.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install vectorized/closedsea
```

To install with [**Hardhat**](https://github.com/nomiclabs/hardhat) or [**Truffle**](https://github.com/trufflesuite/truffle):

```sh
npm install closedsea
```

## Acknowledgements

This repository is inspired by and directly modified from:

- [operator-filter-registry](https://github.com/ProjectOpenSea/operator-filter-registry)

[npm-shield]: https://img.shields.io/npm/v/closedsea.svg
[npm-url]: https://www.npmjs.com/package/closedsea

[ci-shield]: https://img.shields.io/github/workflow/status/vectorized/closedsea/ci?label=build
[ci-url]: https://github.com/vectorized/closedsea/actions/workflows/ci.yml

[license-shield]: https://img.shields.io/badge/License-MIT-green.svg
[license-url]: https://github.com/vectorized/closedsea/blob/main/LICENSE.txt
