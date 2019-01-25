# Disclaimer
Contract code under development still. Expect things to still be broken or unfinished. 

## Local Testing
This project uses clevis to build/deploy and test contracts. The library is still a bit rough around the edges, so excuse the workflow.

To run tests:
```
git clone git@github.com:dbe/vending-machine.git
cd vending-machine
npm i
npm run clevis init
```
You can just accept the defaults for the directories in clevis init. Now to run tests just run:

```
npm run clevis test VendingMachine
```

You will need a local blockchain running (Something like Ganache) and make sure your clevis.json file is pointed to it.

## Notes
The design decisions made for this contract are different than an ideal, or more general purpose contract would make.

### Ideal contract
A few notable features that the ideal contract would have (which the ETHDenver one does not have):
- Not allow for minting or burning of the ERC20 except by the VendingMachine, and only in accord to depositing or withdrawing. This would mean that all outstanding ERC20 tokens are fully collateralized.
- Not have a sweep functionality by admins. This is important to keep the full collateral invariant mentioned above.


## System functional description

### Vending Machine
The Vending Machine is the interface between two currencies. In ETHDenver's case, one is xDai, and the other is BuffiDai. The Machine allows unlimited purchase of BuffiDai with xDai at a rate of 1-to-1. It also keeps track of whitelisted users who can go the other way, purchasing xDai with BuffiDai at the same rate.

The VendingMachine has admins who can whitelist users and manage state. In the ideal contract these admins wouldn't exist, and all functionality would be unpermissioned except maybe specifying the whitelisted users.

The VendingMachine also keeps track of Vendors and their Products, giving users an easy way to purchase goods at set prices. This part is not necessary to be part of the VendingMachine, but is included for convienience and easy sharing of admin capabilities.

### Roles
#### Super Admin
- There is only 1, this role is immutable.
- Can add and remove admins.
- Can sweep the funds of the contract without needing to call withdraw

#### Admin
- Can mint the ERC20 token without depositing real money
- Can update vendors attributes, including disabling them.

#### Whitelisted
- Can withdraw funds
