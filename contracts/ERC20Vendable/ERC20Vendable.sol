pragma solidity 0.4.25;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract ERC20Vendable is ERC20 {
  address public creator;
  string public name;
  string public symbol;
  uint8 public decimals = 18;

  constructor(string memory _name, string memory _symbol) public {
      creator = msg.sender;
      name = _name;
      symbol = _symbol;
  }

  modifier onlyCreator() {
    require(msg.sender == creator);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address to, uint256 amount) public onlyCreator returns (bool) {
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
  function burn(address from, uint256 value) public onlyCreator returns (bool) {
    _burn(from, value);
    return true;
  }
}
