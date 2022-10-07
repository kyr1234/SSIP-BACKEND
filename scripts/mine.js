const {move_blocks}=require("../utils/moveblocks")
const sleeptime=1000
const blocks=2

const mine=async()=>{
   await move_blocks(blocks,(sleepAmount=sleeptime))
}
mine().then(()=>process.exit(0)).catch(()=>process.exit(1))