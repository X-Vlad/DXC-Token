// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

contract DXCtoken {
	event Transfer(address indexed _from, address indexed _to, uint _amount);
	event Approval(address indexed _owner, address indexed _spender, uint _amount);

	string public constant name = "DXC Token";
	string public constant symbol = "DXC";
	uint8 public constant decimals = 6;

	uint256 public _totalSupply = 1000000000;
	uint256 public _amountDev = 10000000;

	address private ownerAddress = 0x8309B604eBC5518539519E09954637cFa86BfA28;
	address private devAddress = 0xa1c76181012f19Af648314e60eF6e5dEd41793E4;

	uint256 private constant _TIMELOCK = 365 days;

	mapping(address => uint256) balances;
	mapping(address => mapping (address => uint256)) allowed;
	mapping(address => uint256) timelock;

	constructor() {
		_totalSupply = _totalSupply * (10 ** decimals);
		_amountDev = _amountDev * (10 ** decimals);

		balances[ownerAddress] = _totalSupply-_amountDev;
		balances[devAddress] = _amountDev;

        emit Transfer(address(0), ownerAddress, balances[ownerAddress]);
        emit Transfer(address(0), devAddress, balances[devAddress]);

		timelock[devAddress] = block.timestamp + _TIMELOCK;
	}

	function totalSupply() public view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address _owner) public view returns (uint) {
		return balances[_owner];
	}

	function approve(address _delegate, uint _amount) public returns (bool) {
		allowed[msg.sender][_delegate] = _amount;
		
		emit Approval(msg.sender, _delegate, _amount);
		
		return true;
	}

	function allowance(address _owner, address _delegate) public view returns (uint) {
		return allowed[_owner][_delegate];
	}

	function transfer(address _to, uint _amount) public returns (bool) {
		require(_amount <= balances[msg.sender]);
		require(timelock[msg.sender] == 0 && timelock[msg.sender] <= block.timestamp, "Address is timelocked");

		balances[msg.sender] -= _amount;
		balances[_to] += _amount;
		
		emit Transfer(msg.sender, _to, _amount);
		
		return true;
	}

	function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
		require(_amount <= balances[_from]);
		require(_amount <= allowed[_from][msg.sender]);
		require(timelock[_from] == 0 && timelock[_from] <= block.timestamp, "Address is timelocked");

		balances[_from] -= _amount;
		balances[_to] += _amount;

        allowed[_from][msg.sender] -= _amount;
		
		emit Transfer(_from, _to, _amount);
		
		return true;
	}
}
