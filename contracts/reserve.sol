// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts@4.4.0/token/ERC20/IERC20.sol";

contract Reserve {
    address constant gameFactoryAddress = 0x25DDbdcADdC6749EaE4C02Eb0c2DAa27118b6857;
    address constant token = 0xb454f9AbecB9f3feF62A446353353db8BDaC9AB0;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed.");
        _;
    }

    function distribute (address _address, uint _amount) external payable onlyOwner {
        address lastGame = BasicGameFactory(gameFactoryAddress).getLastGame();
        if (BasicGame(lastGame).isPayablePlayer(_address)) {
            IERC20(token).transfer(_address, _amount);
        }
    }
}

interface BasicGameFactory {
    function getLastGame() external view returns (address);
}

interface BasicGame {
    function isPayablePlayer(address _address) external view returns(bool);
}