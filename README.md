# mcf-stakingpool
MCF Staking Pool

# install prettier
npm install --save-dev prettier prettier-plugin-solidity

# run prettier
npx prettier --write 'contracts/**/*.sol'

truffle compoile -all
truffle migarte --netwrok roster -reset

# hdwallet-provider 1.0.40
@truffle/hdwallet-provider@1.0.40