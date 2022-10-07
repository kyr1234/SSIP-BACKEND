const { ethers, network } = require('hardhat')
const { move_blocks } = require('../utils/moveblocks')
const PRICE = ethers.utils.parseEther('0.1')
const { developmentChains } = require('../hardhat-helper')
async function mint() {
  const basicNft = await ethers.getContract('Landmint')

  console.log('Minting NFT...')
  const mintTx = await basicNft.mintLand()
  const mintTxReceipt = await mintTx.wait(1)
  const tokenId = mintTxReceipt.events[0].args.tokenId
  console.log(`TokenId=${tokenId}`)
  console.log(`Nft Address: ${basicNft.address}`)

  if (developmentChains.includes(network.name)) {
    await move_blocks(2, (sleepTime = 1000))
  }
}

mint()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
