const { network } = require('hardhat')

function sleep(timeMs) {
  return new Promise((resolve) => setTimeout(resolve, timeMs))
}

async function move_blocks(amount, sleepTime) {
  console.log('Moving Blocks')
  for (let index = 0; index < amount; index++) {
    await network.provider.request({
      method: 'evm_mine',
      params: [],
    })
    if (sleepTime) {
      console.log(`SLEEPING FOR TIME ${sleepTime}`)
      await sleep(sleepTime)
    }
  }
}

module.exports = {
  move_blocks,
  sleep,
}
