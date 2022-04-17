// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTFactory {
    address private lastNFT;

    function createNFT(
        string memory _nftName,
        string memory _nftSymbol,
        string memory _nftDescription
    ) external {
        EdenNFT edenNFT = new EdenNFT(_nftName, _nftSymbol, _nftDescription);
        lastNFT = address(edenNFT);
    }

    function getLastNFT() external view returns(address) {
        return lastNFT;
    }

    function safeMint(address to, string memory uri) external {
        EdenNFT(lastNFT).safeMint(to, uri);
    }
}

contract EdenNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    string private _description;

    constructor(string memory name_, string memory symbol_, string memory description_) ERC721(name_, symbol_) {
        _description = description_;
    }

    function getInfo() external view returns (string memory, string memory, string memory) {
        return (name(), symbol(), _description);
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        _safeMint(to, 1);
        _setTokenURI(1, uri);
    }
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}