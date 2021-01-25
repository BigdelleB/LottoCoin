pragma solidity ^0.7.0;

import './Utils.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20Pausable.sol';

/**
    ERC20 Standard Token implementation
*/
contract LottoToken is ERC20Burnable, ERC20Pausable, Ownable, Utils {
	string public standard = 'LottoToken';
	uint GameId = 0;

	/**
	*	@dev constructor
	*
	*/
    constructor () public
	ERC20("LottoToken", "LTT")
	{
		_mint(_msgSender(), 100000000000);
	}

	/**
		 @dev renounceOwnership disabled
	*/

	function renounceOwnership() public override {
		revert("renouncing ownership is blocked");
	}

	/**
		 @dev _beforeTokenTransfer
	*/

	function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
		super._beforeTokenTransfer(from, to, amount);
	}


	function random() private view returns (uint8) {
    	return uint8(uint256(keccak256(block.timestamp, block.difficulty)) % 1000000);
   	}
	/**
		 @dev BuyTicket
	*/

	function BuyTicket() external payable {
		_transfer(owner(), _msgSender(), random());
	}

	/**
		 @dev ExchangeTicket
	*/

	function ExchangeTicket(uint256 amount) public {
		_burn(_msgSender(), amount);
		_transfer(owner(), _msgSender(), random());
	}

	/**
		 @dev EndGame
	*/

	function EndGame() internal {

	}
}
