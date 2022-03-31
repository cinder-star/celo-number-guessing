// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.4.0/token/ERC20/IERC20.sol";

contract BasicGame {
    bytes32 private secretNumber;
    int maxAttemps;
    string[] private hints;
    address[] private winners;
    address owner;
    address token;
    address reserve;

    constructor(string[] memory _hints, bytes32 _secretNumber, int _maxAttempts) {
        owner = msg.sender;
        hints = _hints;
        token = 0x1D0Ae71a8A5536D4D47eE057d986eEB872A8d2F4;
        reserve = 0xaaB762c4a13C188054C172ee001347EB80F5E6dC;
        secretNumber = _secretNumber;
        maxAttemps = _maxAttempts;
    }
}