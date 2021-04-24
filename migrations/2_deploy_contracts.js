const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const Stakingpool = artifacts.require('Stakingpool');

// https://docs.openzeppelin.com/upgrades-plugins/1.x/truffle-upgrades
module.exports = async function (deployer) {
  const instance = await deployProxy(Stakingpool, ["0x00000", "0x00000"], { deployer });
  console.log('Deployed', instance.address);
};