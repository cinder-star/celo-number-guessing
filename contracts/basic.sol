// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.4.0/token/ERC20/IERC20.sol";

contract GameFactory {
    address token = 0xb454f9AbecB9f3feF62A446353353db8BDaC9AB0;
    address reserve = 0xaaB762c4a13C188054C172ee001347EB80F5E6dC;

    event GameCreated(address _address);

    function createbasicGame(string[] memory _hints, bytes32 _secretNumber, int _maxAttempts) public {
        BasicGame basicGame = new BasicGame(_hints, _secretNumber, _maxAttempts);
        emit GameCreated(address(basicGame));
    }
}


contract BasicGame {
    bytes32 private secretNumber;
    int maxAttemps;
    string[] private hints;
    address[] private winners;
    address owner;

    constructor(string[] memory _hints, bytes32 _secretNumber, int _maxAttempts) {
        owner = msg.sender;
        hints = _hints;
        secretNumber = _secretNumber;
        maxAttemps = _maxAttempts;
    }

    function attepmt (string memory _guess) external view returns (bool) {
        return keccak256(abi.encodePacked(_guess)) == secretNumber;
    }
}