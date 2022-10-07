const { ethers, network } = require('hardhat')
const { move_blocks } = require('../utils/moveblocks')
const { developmentChains } = require('../hardhat-helper')
const TOKEN_ID = 4

async function cancel() {
  const nftMarketplace = await ethers.getContract('NftMarketplace')
  const basicNft = await ethers.getContract('BasicNft')
  const tx = await nftMarketplace.cancelListing(basicNft.address, TOKEN_ID)
  await tx.wait(1)
  console.log('NFT Canceled!')
  if (developmentChains.includes(network.name)) {
    await move_blocks(2, (sleepTime = 1000))
  }
}

cancel()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
