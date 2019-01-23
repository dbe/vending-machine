pragma solidity 0.4.25;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "ERC20Vendable.sol";

contract AdminRole {
  using Roles for Roles.Role;

  event AdminAdded(address indexed account);
  event AdminRemoved(address indexed account);

  Roles.Role private admins;

  constructor() public {
    _addAdmin(msg.sender);
  }

  modifier onlyAdmin() {
    require(isAdmin(msg.sender));
    _;
  }

  function isAdmin(address account) public view returns (bool) {
    return admins.has(account);
  }

  function addAdmin(address account) public onlyAdmin {
    _addAdmin(account);
  }

  function renounceAdmin() public {
    _removeAdmin(msg.sender);
  }

  function _addAdmin(address account) internal {
    admins.add(account);
    emit AdminAdded(account);
  }

  function _removeAdmin(address account) internal {
    admins.remove(account);
    emit AdminRemoved(account);
  }
}

contract WhitelistedRole is AdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

contract VendingMachine is AdminRole, WhitelistedRole {
  ERC20Vendable public tokenContract;

  event Deposit(address indexed depositor, uint amount);
  event Withdraw(address indexed withdrawer, uint amount);

  constructor() public {
    //TODO: Make this paramaterizable potentially
    tokenContract = new ERC20Vendable("DenDai", "DEN");
  }

  //Fallback. Just send currency here to deposit
  function () external payable {
    deposit();
  }

  function deposit() public payable {
    tokenContract.mint(msg.sender, msg.value);
    emit Deposit(msg.sender, msg.value);
  }

  function withdraw(uint256 amount) public onlyWhitelisted {
    tokenContract.burn(msg.sender, amount);
    msg.sender.transfer(amount);

    emit Withdraw(msg.sender, amount);
  }

  //TODO: Decide if we want to trust the admin system enough to allow this form of functionality
  function sweep(uint256 amount) public onlyAdmin {
      msg.sender.transfer(amount);
  }

  //*****************  Product/Vendor related code *******************//

  mapping (address => Vendor) public vendors;
  /* mapping (address => uint32) public productCount;
  mapping (address => mapping (uint256 => Product)) public products; */

  event UpdateVendor(address indexed vendorAddress, bytes32 name, bool isAllowed, bool isActive, address sender);

  struct Vendor {
    bytes32 name;
    bool isActive; //let's vendor indicate if they are open at the time
    bool isAllowed; //let's admin turn them off,
    bool exists;
  }

  /* struct Product {
    uint256 id;
    uint256 cost;
    bytes32 name;
    bool exists;
    bool isAvailable;
  } */

  function addVendor(address _vendorAddress, bytes32 _name) public onlyAdmin {
    require(!vendors[_vendorAddress].exists, "This address already is a vendor.");

    vendors[_vendorAddress] = Vendor({
      name: _name,
      isActive: false,
      isAllowed: true,
      exists: true
    });

    _emitUpdateVendor(_vendorAddress);
  }

  function activateVendor(bool _isActive) public {
    //Existing vendor check happens in _updateVendor. No need to do it here
    _updateVendor(
      msg.sender,
      vendors[msg.sender].name,
      _isActive,
      vendors[msg.sender].isAllowed
    );
  }

  function updateVendor(address _vendorAddress, bytes32 _name, bool _isActive, bool _isAllowed) public onlyAdmin {
    _updateVendor(_vendorAddress, _name, _isActive, _isAllowed);
  }

  function _updateVendor(address _vendorAddress, bytes32 _name, bool _isActive, bool _isAllowed) private {
    require(vendors[_vendorAddress].exists, "Cannot update a non-existent vendor");

    vendors[_vendorAddress].name = _name;
    vendors[_vendorAddress].isActive = _isActive;
    vendors[_vendorAddress].isAllowed = _isAllowed;

    _emitUpdateVendor(_vendorAddress);
  }

  function _emitUpdateVendor(address _vendorAddress) private {
    emit UpdateVendor(
      _vendorAddress,
      vendors[_vendorAddress].name,
      vendors[_vendorAddress].isActive,
      vendors[_vendorAddress].isAllowed,
      msg.sender
    );
  }
}
