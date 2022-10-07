const { ethers, network } = require('hardhat')
const { move_blocks } = require('../utils/moveblocks')
const PRICE = ethers.utils.parseEther('0.1')
const { developmentChains } = require('../hardhat-helper')
async function mintAndList() {
  const nftMarketplace = await ethers.getContract('NftMarketplace')

  const basicNft = await ethers.getContract('Landmint')

  console.log('Minting NFT...')
  const mintTx = await basicNft.mintLand()
  const mintTxReceipt = await mintTx.wait(1)
  const tokenId = mintTxReceipt.events[0].args.tokenId
  console.log('Approving NFT...')
  const approvalTx = await basicNft.approve(nftMarketplace.address, tokenId)
  await approvalTx.wait(1)
  console.log('Listing NFT...')
  const tx = await nftMarketplace.Listitem(basicNft.address, tokenId, PRICE)
  await tx.wait(1)
  console.log('NFT Listed!')
  const listednft = await nftMarketplace.getListing(basicNft.address, tokenId)
  console.log(listednft)
  if (developmentChains.includes(network.name)) {
    await move_blocks(2, (sleepTime = 1000))
  }
}

mintAndList()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
