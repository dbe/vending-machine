/* global before  */

const expect = require('chai').expect
const clevis = require('clevis')
// const BN = web3.utils.BN;

describe('VendingMachine', function() {
  this.timeout(15000);

  let accounts = []
  before(async function() {
    accounts = await clevis('accounts')
    await clevis('compile', 'VendingMachine')
    await clevis('deploy', 'VendingMachine', '0')
  });

  it("should create a ERC20Vendable token", async function () {
    let balance = await clevis('contract', 'balanceOf', 'ERC20Vendable', accounts[0])
    expect(balance, "Should start with 0 balance").to.equal('0');
  })
})
