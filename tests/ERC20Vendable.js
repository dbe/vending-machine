/* global before  */

const expect = require('chai').expect
const clevis = require('clevis')
// const BN = web3.utils.BN;

describe('ERC20Vendable', function() {
  this.timeout(15000);

  let accounts = []
  before(async function() {
    accounts = await clevis('accounts')
    await clevis('compile', 'ERC20Vendable')
    await clevis('deploy', 'ERC20Vendable', '0')
  });

  it("should create a ERC20Vendable token", async function () {
    let balance = await clevis('contract', 'balanceOf', 'ERC20Vendable', accounts[0])
    expect(balance, "Should start with 0 balance").to.equal('0');
  })
})
