// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts@4.4.0/token/ERC20/IERC20.sol";

contract Reserve {
    address constant token = 0xb454f9AbecB9f3feF62A446353353db8BDaC9AB0;
    mapping (address => uint) private balance;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier isBalanceRemaining() {
        require(balance[msg.sender] > 0, "No balance remaining");
        _;
    }

    function receiveFunds(address _gameAddress, uint _amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        balance[_gameAddress] += _amount;
    }

    function distribute (address _address, uint _amount) external payable isBalanceRemaining {
        if (BasicGame(msg.sender).isPayablePlayer(_address)) {
            IERC20(token).transfer(_address, _amount);
        }
    }
}

interface BasicGame {
    function isPayablePlayer(address _address) external view returns(bool);
}