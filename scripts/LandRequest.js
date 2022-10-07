const { ethers, network } = require('hardhat')
const { move_blocks } = require('../utils/moveblocks')
const PRICE = ethers.utils.parseEther('0.1')
const { developmentChains } = require('../hardhat-helper')
async function mintAndList() {
  const Land = await ethers.getContract('Land')
  const Landmint = await ethers.getContract('Landmint')
  console.log('Minting NFT...')
  const mintTx = await Landmint.mintLand()
  const mintTxReceipt = await mintTx.wait(1)
  const tokenId = mintTxReceipt.events[0].args.tokenId
  console.log('Approving NFT...')
  const approvalTx = await Landmint.approve(Land.address, tokenId)
  await approvalTx.wait(1)
  console.log('Listing NFT...')
  const tx = await Land.registerUser(
    'Yug',
    10,
    'surat',
    '929134955538',
    'EPZIPR36',
    'bafybeig3zsdpfw4cg43flxtfpedsknbjjtzdeth7lr2nff7kcjyzsx4fje',
    'yugkhokhar18@gmail.com',
  )

  await tx.wait(1)
  console.log('User Reigstration!')
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
