pragma solidity ^0.7.0;

import './access/Ownable.sol';
import './token/ERC20Burnable.sol';
import './token/ERC20Pausable.sol';

/**
    ERC20 Standard Token implementation
*/

contract LottoToken is ERC20Burnable, ERC20Pausable {
        using SafeMath for uint256;
        
        string public standard = 'LottoToken';
        uint MaxRand = 1000;
    	uint public MinBuyAmount = 0.001 ether;
    	uint256 public MinExchangeAmount = 100;

        event EventRand(uint256 amount); // Event

        /**
        *       @dev constructor
        *
        */
    constructor () public
        ERC20("LottoToken", "LTT")
        {
                _mint(_msgSender(), 100000000 * (10 ** 18));
        }

        /**
                 @dev _beforeTokenTransfer
        */

        function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
                super._beforeTokenTransfer(from, to, amount);
        }


        function random() private view returns (uint256) {
            return uint256(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % MaxRand + 1) * (10 ** 18);
        }
        /**
                 @dev BuyTicket
        */

        function BuyTicket() external payable {
                require(msg.value >= MinBuyAmount, "Amount is not enough to buy");
                uint256 rand = random();
                emit EventRand(rand);
                _transfer(owner(), _msgSender(), random());
                MinBuyAmount = MinBuyAmount + 0.00001 ether;
                _gameEndCheck();
    	}

        /**
                 @dev ExchangeTicket
        */

        function ExchangeTicket() public {
                require(balanceOf(_msgSender()) >= MinExchangeAmount * (10 ** 18), "You don't have enough token to exchange");
                _burn(_msgSender(), MinExchangeAmount * (10 ** 18));
                MinExchangeAmount.add(1);
                _transfer(owner(), _msgSender(), random());
                _gameEndCheck();
        }


        /**
                 @dev ExchangeTicket
        */

        function withdraw(uint amount, address payable _to) public onlyOwner {
            require(address(this).balance >= amount);
            _to.call{value: amount}("");
        }
        
}