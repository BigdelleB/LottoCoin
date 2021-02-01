// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;

import './access/Ownable.sol';
import './token/ERC20Burnable.sol';
import './token/ERC20Pausable.sol';

/**
    ERC20 Standard Token implementation
*/
contract LottoToken is ERC20Burnable, ERC20Pausable, Ownable {
	string public standard = 'LottoToken';
	uint GameId = 0;
	uint MaxRand = 1000;
	
	event EventRand(uint16 amount); // Event

	/**
	*	@dev constructor
	*
	*/
    constructor () public
	ERC20("LottoToken", "LTT")
	{
		_mint(_msgSender(), 100000000);
	}

	/**
		 @dev _beforeTokenTransfer
	*/

	function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
		super._beforeTokenTransfer(from, to, amount);
	}


	function random() private view returns (uint16) {
    	return uint16(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % MaxRand) + 1;
   	}
	/**
		 @dev BuyTicket
	*/

	function BuyTicket() external payable EndGame() {
		require(msg.value < 0.1 ether, "Amount is not enoough to buy");
	    uint16 rand = random();
	    emit EventRand(rand);
		_transfer(owner(), _msgSender(), random());
	}

	/**
		 @dev ExchangeTicket
	*/

	function ExchangeTicket(uint256 amount) public EndGame() {
		_burn(_msgSender(), amount);
		_transfer(owner(), _msgSender(), random());
	}

	/**
		 @dev EndGame
	*/

	modifier EndGame() {
		if (uint(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 10000) == 1) {
			GameId = GameId + 1;
		}
		_;
	}
}
