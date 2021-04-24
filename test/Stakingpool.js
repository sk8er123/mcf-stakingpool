const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const Stakingpool = artifacts.require('Stakingpool');
const StakingpoolV2 = artifacts.require('StakingpoolV2');

describe('upgrades', () => {
  it('works', async () => {
    const stakingpool = await deployProxy(Stakingpool, ["0x000", "0x000"]);
    const stakingpoolV2 = await upgradeProxy(stakingpool.address, StakingpoolV2);

    const value = await stakingpoolV2.value();
    assert.equal(value.toString(), "0x000");
  });
});