// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.4.0/token/ERC20/IERC20.sol";

contract GameFactory {
    BasicGame lastgame;

    function createbasicGame(string[] memory _hints, bytes32 _secretNumber, uint _maxAttempts) external {
        BasicGame basicGame = new BasicGame(_hints, _secretNumber, msg.sender, _maxAttempts);
        lastgame = basicGame;
    }

    function getLastGame() external view returns (address) {
        return address(lastgame);
    }
}


contract BasicGame {
    bytes32 private secretNumber;
    uint maxAttemps;
    string[] private hints;
    address public owner;
    mapping (address => bool) winners;
    mapping (address => uint) attempts;

    address constant token = 0xb454f9AbecB9f3feF62A446353353db8BDaC9AB0;

    constructor(string[] memory _hints, bytes32 _secretNumber, address _owner, uint _maxAttempts) {
        owner = _owner;
        hints = _hints;
        secretNumber = _secretNumber;
        maxAttemps = _maxAttempts;
    }

    event GameResult(string _msg);
    event HashLog(bytes32 _msg);
    
    modifier eligiblePlayer() {
        require(msg.sender != owner, "Owner can't perticipate in own game");
        require(winners[msg.sender] != true, "Winners can't participate");
        require(attempts[msg.sender] < maxAttemps, "No attempts remaining");
        _;
    }

    function attempt (bytes32 _guess) private view returns (bool) {
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(_guess)))) == secretNumber;
    }

    function play(bytes32 _guess) external payable eligiblePlayer {
        if (attempt(_guess)) {
            IERC20(token).transfer(msg.sender, 5 * 10**18);
            winners[msg.sender] = true;
            emit GameResult("Success");
        } else {
            attempts[msg.sender] += 1;
            emit GameResult("Failed");
        }
    }
}