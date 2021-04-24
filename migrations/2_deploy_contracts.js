const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const StakingpoolV1 = artifacts.require('StakingpoolV1');

// https://docs.openzeppelin.com/upgrades-plugins/1.x/truffle-upgrades
module.exports = async function (deployer) {
  const instance = await deployProxy(StakingpoolV1, [1], { deployer });
  console.log('Deployed', instance.address);
};