pragma solidity ^0.7.0;

import './access/Ownable.sol';
import './token/ERC20Pausable.sol';

/**
    Lotto Token implementation
*/

contract LottoToken is Ownable, ERC20Pausable {
    using SafeMath for uint256;
    
    string public standard = 'LottoToken';
    uint MaxRand = 1000;
    uint public MinBuyAmount = 0.001 ether;
    uint256 public MinExchangeAmount = 100;

    address private wallet;
    address private teamReserve;
    uint256 weiRaised;

    event EventRand(uint256 amount); // Event

    /**
    *       @dev constructor
    *
    */
    constructor (address _wallet, address _teamReserve) public
    ERC20("LottoToken", "LTT")
    {
        teamReserve = _teamReserve;
        wallet = _wallet;
        _mint(address(this), 999000000 * (10 ** 18));
        _mint(_teamReserve, 1000000 * (10 ** 18));
    }

    /**
        @dev _beforeTokenTransfer
    */

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }


    function random() private view returns (uint256) {
        return uint256(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % MaxRand + 1) * (10 ** 18);
    }
    /**
        @dev BuyTicket
    */

    /**
        @dev Game End Check
    */

    function _gameEndCheck() internal virtual {
        if (uint(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 10000) == 1) {
            _incraseGameId();
            _mint(address(this), 99900000 * (10 ** 18));
            _mint(teamReserve, 100000 * (10 ** 18));
        }
    }

    function BuyTicket() external payable {
        require(msg.value >= MinBuyAmount, "Amount is not enough to buy");
        weiRaised = weiRaised.add(msg.value);
        uint256 rand = random();
        emit EventRand(rand);
        _transfer(address(this), _msgSender(), random());
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
        _transfer(address(this), _msgSender(), random());
        _gameEndCheck();
    }


    /**
        @dev changeWallet
    */

    function changeWallet(address _newWallet) public onlyOwner {
        require(_newWallet != address(0), 'Not valid address');
        wallet = _newWallet;
    }


    /**
        @dev Withdraw
    */

    function withdraw(uint256 amount) public onlyOwner {
        require(weiRaised >= amount, 'Not enough balance');
        weiRaised = weiRaised.sub(amount);
        (bool sent, ) = wallet.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
        
}