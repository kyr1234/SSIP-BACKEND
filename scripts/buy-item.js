const { ethers, network } = require('hardhat')
const { move_blocks } = require('../utils/moveblocks')
const { developmentChains } = require('../hardhat-helper')
const TOKEN_ID = 5

async function buyItem() {
  const nftMarketplace = await ethers.getContract('NftMarketplace')
  const basicNft = await ethers.getContract('BasicNft')
  const listing = await nftMarketplace.getListing(basicNft.address, TOKEN_ID)
  const price = listing.price.toString()
  const tx = await nftMarketplace.buyItem(basicNft.address, TOKEN_ID, {
    value: price,
  })
  await tx.wait(1)
  console.log('NFT Bought!')
  if (developmentChains.includes(network.name)) {
    await move_blocks(2, (sleepAmount = 1000))
  }
}

buyItem()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
