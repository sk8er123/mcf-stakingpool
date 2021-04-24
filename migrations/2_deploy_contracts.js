const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const Stakingpool = artifacts.require('Stakingpool');

// https://docs.openzeppelin.com/upgrades-plugins/1.x/truffle-upgrades
module.exports = async function (deployer) {
  const instance = await deployProxy(Stakingpool, ["0xf285112f01928ecc9c49a879fac6909032742fcd", "0x7b481121fbf7a0727589b1b25e4e7a7948ae168b"], { deployer });
  console.log('Deployed', instance.address);
};