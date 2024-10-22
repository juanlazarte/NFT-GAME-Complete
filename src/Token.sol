// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NotZeroAddress();
error ExceedsBalance();

contract TokenShock is Context, IERC20, IERC20Metadata, Ownable {
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    address public marketingAddress;
    address public poolRewardAddress;
    address public pair;

    // Tax System
    uint256 public _feeBuySellTotal = 10;

    uint256 public _feeBuySellReward = 4;
    uint256 public _feeBuySellMK = 3;
    uint256 public _feeBuySellBurn = 3;

    enum Flag {
        None,
        Sell,
        Buy
    }

    mapping(address => bool) public is_taxless;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(address _marketingAdd, address _poolRewardAdd) Ownable(msg.sender) {
        _name = "SHOCK";
        _symbol = "SHOCK";
        marketingAddress = _marketingAdd;
        poolRewardAddress = _poolRewardAdd;

        is_taxless[msg.sender] = true;
        is_taxless[marketingAddress] = true;
        is_taxless[poolRewardAddress] = true;
        is_taxless[address(this)] = true;
        is_taxless[address(0)] = true;
        _mint(msg.sender, 21_000_000 * (10 ** decimals()));
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        if (owner == address(0)) {
            revert NotZeroAddress();
        }
        if (spender == address(0)) {
            revert NotZeroAddress();
        }

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        if (account == address(0)) {
            revert NotZeroAddress();
        }

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        if (account == address(0)) {
            revert NotZeroAddress();
        }

        uint256 accountBalance = _balances[account];
        if (accountBalance < amount) {
            revert ExceedsBalance();
        }

        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (from == address(0)) {
            revert NotZeroAddress();
        }
        if (to == address(0)) {
            revert NotZeroAddress();
        }

        uint256 fromBalance = _balances[from];
        if (fromBalance < amount) {
            revert ExceedsBalance();
        }

        uint256 taxAmount = 0;
        Flag flag = Flag.None;

        if (!is_taxless[from] && !is_taxless[to]) {
        if (to == pair) {
                taxAmount = amount * _feeBuySellTotal / 100;
                flag = Flag.Sell;
            } else if (from == pair) {
                taxAmount = amount * _feeBuySellTotal / 100;
                flag = Flag.Buy;
            }
        }

        if (taxAmount > 0) {
            uint256 burnAmount = taxAmount * _feeBuySellBurn / _feeBuySellTotal;
            uint256 mkAmount = taxAmount * _feeBuySellMK / _feeBuySellTotal;
            uint256 rewardAmount = taxAmount * _feeBuySellReward / _feeBuySellTotal;

            _burn(from, burnAmount);
            _balances[marketingAddress] += mkAmount;
            _balances[poolRewardAddress] += rewardAmount;

            emit Transfer(from, address(0), burnAmount);
            emit Transfer(from, marketingAddress, mkAmount);
            emit Transfer(from, poolRewardAddress, rewardAmount);
        }

        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount - taxAmount;

        emit Transfer(from, to, amount - taxAmount);
    }

    // My Functions
    function setPair(address _pair) public onlyOwner {
        pair = _pair;
    }

    function setMarketingAdd(address _address) public onlyOwner {
        marketingAddress = _address;
        is_taxless[_address] = true;
    }

    function setPoolRewardAdd(address _address) public onlyOwner {
        poolRewardAddress = _address;
        is_taxless[_address] = true;
    }

    function editFees(uint256 _newFeeReward, uint256 _newFeeMk, uint256 _newFeeBurn) external onlyOwner {
        _feeBuySellReward = _newFeeReward;
        _feeBuySellMK = _newFeeMk;
        _feeBuySellBurn = _newFeeBurn;
    }
}