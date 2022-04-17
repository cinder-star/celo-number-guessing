// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts@4.4.0/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EdenGameFactory {
    address private lastGame;
    address private basicGameFactoryAddress = 0x25DDbdcADdC6749EaE4C02Eb0c2DAa27118b6857;
    address private erc20Token = 0xb454f9AbecB9f3feF62A446353353db8BDaC9AB0;

    function createEdenGame (
        bytes32 _secretNumber,
        string[] memory _hints,
        uint _minimumStakeAmount,
        string memory _nftName,
        string memory _nftSymbol,
        string memory _nftDescription,
        string memory _nftURI) external 
    {
        // Cheking eligibilty requirement
        address lastBasicGame = BasicGameFactory(basicGameFactoryAddress).getLastGame();
        require(BasicGame(lastBasicGame).isWinner(msg.sender), "Not Eligible");
        require(IERC20(erc20Token).balanceOf(msg.sender) >= 3 * 10**18, "Not enough balance");

        // Staking Eden tokens
        IERC20(erc20Token).transferFrom(msg.sender, address(this), 3 * 10**18);

        // Minting NFT
        EdenNFT edenNFT = new EdenNFT(_nftName, _nftSymbol, _nftDescription);
        lastGame = address(new EdenGame(msg.sender, _secretNumber, _hints, _minimumStakeAmount, address(edenNFT)));
        edenNFT.safeMint(lastGame, _nftURI);

        // Staking Eden Tokens
        IERC20(erc20Token).transfer(lastGame, 3 * 10**18);
    }

    function getLastGame() external view returns(address) {
        return lastGame;
    }
}

contract EdenGame {
    address public owner;
    string[] private hints;
    bytes32 private secretNumber;
    uint minimumStakeAmount;
    bool private distributed;
    address private nftAddress;
    mapping (address => bool) private participants;

    address private basicGameFactoryAddress = 0x25DDbdcADdC6749EaE4C02Eb0c2DAa27118b6857;
    address private erc20Token = 0xb454f9AbecB9f3feF62A446353353db8BDaC9AB0;

    constructor(address _owner, bytes32 _secretNumber, string[] memory _hints, uint _minimumStakeAmount, address _nftAddress) {
        owner = _owner;
        secretNumber = _secretNumber;
        hints = _hints;
        minimumStakeAmount = _minimumStakeAmount;
        nftAddress = _nftAddress;
    }

    modifier eligibleForGame() {
        address lastBasicGame = BasicGameFactory(basicGameFactoryAddress).getLastGame();
        require(!distributed, "Game ended");
        require(msg.sender != owner, "Owner can't participate");
        _;
    }

    modifier eligiblePlayer() {
        require(participants[msg.sender], "You must participate first");
        _;
    }

    event GameResult(string _msg);

    function getGameInfo() external view returns(string[] memory, uint) {
        return (hints, minimumStakeAmount);
    }

    function attempt (bytes32 _guess) private view returns (bool) {
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(_guess)))) == secretNumber;
    }

    function participate () external {
        IERC20(erc20Token).transferFrom(msg.sender, address(this), minimumStakeAmount);
        participants[msg.sender] = true;
    }

    function play (bytes32 _guess) external payable eligibleForGame eligiblePlayer {
        if (attempt(_guess)) {
            IERC721(nftAddress).safeTransferFrom(address(this), msg.sender, 1);
            IERC20(erc20Token).transfer(owner, 3 * 10**18);
            distributed = true;
            emit GameResult("Success");
        } else {
            emit GameResult("Failed");
        }
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

    function safeMint(address to, string memory uri)
        public
        onlyOwner
    {
        _safeMint(to, 1);
        _setTokenURI(1, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}

interface BasicGameFactory {
    function getLastGame() external view returns (address);
}

interface BasicGame {
    function isWinner(address _address) external view returns(bool);
}