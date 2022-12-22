const {
  frontEndContractsFile,
  frontEndAbiLocation,
} = require('../hardhat-helper')
require('dotenv').config()
const fs = require('fs')
const { network, ethers } = require('hardhat')

module.exports = async () => {
  if (process.env.UPDATE_IN_FRONTEND) {
    console.log('Writing to front end...')
    await updateContractAddresses()
    await updateAbi()
    console.log('Front end written!')
  }
}

async function updateAbi() {
  const nftMarketplace = await ethers.getContract('Land')
  fs.writeFileSync(
    `${frontEndAbiLocation}Land.json`,
    nftMarketplace.interface.format(ethers.utils.FormatTypes.json),
  )
}

async function updateContractAddresses() {
  const chainId = network.config.chainId && network.config.chainId.toString()
  const nftMarketplace = await ethers.getContract('Land')
  const contractAddresses = JSON.parse(
    fs.readFileSync(frontEndContractsFile, 'utf8'),
  )
  if (chainId in contractAddresses) {
    if (!contractAddresses[chainId]['Land'].includes(nftMarketplace.address)) {
      contractAddresses[chainId]['Land'].push(nftMarketplace.address)
    }
  } else {
    contractAddresses[chainId] = { Land: [nftMarketplace.address] }
  }
  fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses))
}
module.exports.tags = ['all', 'frontend']
