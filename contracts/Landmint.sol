// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Landmint is ERC721 {
    uint256 private s_tokenCounter;

    event LandMinted(uint256 indexed tokenId);

    constructor() ERC721("LandMineAsset", "LDA") {
        s_tokenCounter = 0;
    }

    function mintLand() public {
        _safeMint(msg.sender, s_tokenCounter);
        emit LandMinted(s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
