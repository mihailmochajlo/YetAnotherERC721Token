// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.3/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.3/utils/Counters.sol";

contract YetAnotherERC721Token is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string _baseUriStr;
    uint8 _maxIndex;

    mapping (uint256 => uint256) listings;

    constructor() ERC721("YetAnotherERC721Token", "YAET") {
        _baseUriStr = "https://nftstorage.link/ipfs/bafybeigf2zetttzzv2qbwe3rejeha7itk5w7bnvtzlii7n2hodox2nrd7m/";
        _maxIndex = 10;
        _tokenIdCounter.increment();
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUriStr;
    }

    function createItem(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId <= _maxIndex, "Maximum minted");
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        return _tokenIdCounter.current() - 1;
    }

    function listItem(uint256 tokenId, uint256 price) public returns (bool) {
        require(ownerOf(tokenId) == msg.sender, "Only owner can list item");
        require(listings[tokenId] == 0, "Item already listed");
        listings[tokenId] = price;
        return true;
    }

    function cancel(uint256 tokenId) public returns (bool) {
        require(ownerOf(tokenId) == msg.sender, "Only owner can cancel listing");
        require(listings[tokenId] != 0, "Item is not listed");
        listings[tokenId] = 0;
        return true;
    }

    function buyItem(uint256 tokenId) public payable returns (bool) {
        require(listings[tokenId] != 0, "Item is not listed");
        require(msg.value >= listings[tokenId], "Ether amount is too low");
        payable(ownerOf(tokenId)).transfer(msg.value);
        _approve(msg.sender, tokenId);
        _transfer(ownerOf(tokenId), msg.sender, tokenId);
        listings[tokenId] = 0;
        return true;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}