/* global before  */

const assert = require('assert')
const clevis = require('clevis')
const { expect } = require('chai')
const fs = require('fs')
const { BN } = require('web3').utils

describe('VendingMachine', function() {
  this.timeout(90000);

  let accounts = []
  let machineAddress;
  let tokenAddress;

  before(async function() {
    accounts = await clevis('accounts')


    //This is just to make sure that we have the abi etc generated.
    //Clevis shouldn't require the contract do be explicitly deployed to fetch the ABI or call contract functions
    await clevis('compile', 'ERC20Vendable')
    await clevis('deploy', 'ERC20Vendable', '0')

    await clevis('compile', 'VendingMachine')
    let result = await clevis('deploy', 'VendingMachine', '0')
    machineAddress = result.contractAddress

    //Hacky.af We need to add a way for clevis to instantiate the contract with a different address
    let tokenAddress = await clevis('contract', 'tokenContract', 'VendingMachine')
    fs.writeFileSync(`${process.cwd()}/contracts/ERC20Vendable/ERC20Vendable.address`, tokenAddress)
  });

  it("should start with a 0 balance", async function () {
    let balance = await clevis('contract', 'totalSupply', 'ERC20Vendable', accounts[0])
    expect(balance, "Should start with 0 balance").to.equal('0');
  })

  it("should configure ERC20Vendable correctly", async function () {
    let creator = await clevis('contract', 'creator', 'ERC20Vendable')
    expect(creator, "Creator should be the VendingMachine").to.equal(machineAddress);
  });

  it("should mint correctly with fallback", async function () {
    const amount = await clevis('fromwei', '1', 'ether')

    await clevis('send', amount, 0, machineAddress)

    return Promise.all([
      clevis('balance', machineAddress, 'wei').then(balance => {
        expect(balance).to.equal('1')
      }),

      clevis('contract', 'balanceOf', 'ERC20Vendable', accounts[0]).then(balance => {
        expect(balance).to.equal('1')
      })
    ]);
  });

  it("should not allow unauthorized withdrawls", async function () {
    let tx = clevis('contract', 'withdraw', 'VendingMachine', 0, 100)
    await assert.rejects(tx, "Should reject this tx")
  });

  it("should allow whitelisted withdrawls", async function () {
    await clevis('contract', 'addWhitelisted', 'VendingMachine', 0, accounts[0])
    let isWhitelisted = await clevis('contract', 'isWhitelisted', 'VendingMachine', accounts[0])
    expect(isWhitelisted).to.equal(true)

    let ercBalance = await clevis('contract', 'balanceOf', 'ERC20Vendable', accounts[0])
    let totalSupplyBefore = await clevis('contract', 'totalSupply', 'ERC20Vendable')

    await clevis('contract', 'withdraw', 'VendingMachine', 0, ercBalance)

    let ercBalanceAfter = await clevis('contract', 'balanceOf', 'ERC20Vendable', accounts[0])
    expect(ercBalanceAfter).to.equal('0')

    let totalSupplyAfter = await clevis('contract', 'totalSupply', 'ERC20Vendable')
    expect(totalSupplyAfter).to.equal(new BN(totalSupplyBefore).sub(new BN(ercBalance)).toString())

    //TODO: Should be testing that the recipient got the correct amount of cash, but gas price with clevis is a pita atm.
  });

  // it("should be able to add a Vendor", async function () {
  //   await VendingMachine.methods.addVendor(
  //     accounts[1],
  //     web3.utils.utf8ToHex("First Vendor")
  //   ).send({from: accounts[0]});
  //
  //   let vendor = await VendingMachine.methods.vendors(accounts[1]).call();
  //   expect(web3.utils.hexToUtf8(vendor.name)).to.equal("First Vendor");
  //   expect(vendor.isActive).to.equal(false);
  //   expect(vendor.isAllowed).to.equal(true);
  //   expect(vendor.exists).to.equal(true);
  // });
  //
  // it("should not be able to add the same vendor twice", async function () {
  //   let tx = VendingMachine.methods.addVendor(
  //     accounts[1],
  //     web3.utils.utf8ToHex("Second Vendor")
  //   ).send({from: accounts[0]});
  //
  //   await assert.rejects(tx, "Should not allow the same vendor to be created twice.");
  // });
  //
  // it("should not be able to add a vendor unless an Administrator", async function () {
  //   let tx = VendingMachine.methods.addVendor(
  //     accounts[2],
  //     web3.utils.utf8ToHex("Third Vendor")
  //   ).send({from: accounts[1]});
  //
  //   await assert.rejects(tx, "Should not allow the a non-admin to create vendors.");
  // });
})
