pragma solidity 0.4.25;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/access/Roles.sol";

contract AdministratorRole {
  using Roles for Roles.Role;

  event AdministratorAdded(address indexed account);
  event AdministratorRemoved(address indexed account);

  Roles.Role private administrators;

  constructor() public {
    _addAdministrator(msg.sender);
  }

  modifier onlyAdministrator() {
    require(isAdministrator(msg.sender));
    _;
  }

  function isAdministrator(address account) public view returns (bool) {
    return administrators.has(account);
  }

  function addAdministrator(address account) public onlyAdministrator {
    _addAdministrator(account);
  }

  function renounceAdministrator() public {
    _removeAdministrator(msg.sender);
  }

  function _addAdministrator(address account) internal {
    administrators.add(account);
    emit AdministratorAdded(account);
  }

  function _removeAdministrator(address account) internal {
    administrators.remove(account);
    emit AdministratorRemoved(account);
  }
}

contract ERC20Vendable is ERC20, AdministratorRole {
  string public name;
  string public symbol;
  uint8 public decimals = 18;

  constructor(string memory _name, string memory _symbol) public {
      name = _name;
      symbol = _symbol;
  }

  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address to, uint256 amount) public onlyAdministrator returns (bool) {
    _mint(to, amount);
    return true;
  }

  /**
   * @dev Burns a specific amount of tokens.
   * This is different then the standard Burnable definition.
   * We only want the vending machine to be able to burn the tokens, but we don't want to require
   * the two step approve and burnFrom which the standard case would require.
   * @param from The address of which tokens should be burned away from.
   * @param value The amount of token to be burned.
   */
  function burn(address from, uint256 value) public onlyAdministrator returns (bool) {
    _burn(from, value);
    return true;
  }
}
