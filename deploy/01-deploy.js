const { network } = require('hardhat')
const { developmentChains } = require('../hardhat-helper')
const { verify } = require('../utils/verify')
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()

  const args = []
  const deployContract = await deploy('Land', {
    from: deployer,
    log: true,
    args: args,
    waitConfirmations: network.config.blockConfirmations || 1,
  })

  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    log('----VERIFYING----')
    await verify(deployContract.address, args)
  }
  log('--------------------------------------')
}

module.exports.tags = ['all', 'main', 'nftmarketplace']
