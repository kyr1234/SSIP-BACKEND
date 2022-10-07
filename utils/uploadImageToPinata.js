const path = require('path')
const fs = require('fs')
require('dotenv').config()
const pinataSDK = require('@pinata/sdk')
const api_key = process.env.PINATA_API_KEY
const api_SECRET_key = process.env.PINATA_SECRET_KEY
const pinata = pinataSDK(api_key, api_SECRET_key)
const uploadimages = async (imagespath) => {
  const fullimagepath = path.resolve(imagespath)
  const files = fs.readdirSync(fullimagepath)
  let responses = []
  for (fileIndex in files) {
    const readablestream = fs.createReadStream(
      `${fullimagepath}/${files[fileIndex]}`,
    )
    try {
      const response = await pinata.pinFileToIPFS(readablestream)
      responses.push(response)
    } catch (error) {
      console.log(error)
    }
  }
  return {
    responses,
    files,
  }
}

const setTokenMetaData = async (metadataTemplate) => {
  const uploadedMetadata = await pinata.pinJSONToIPFS(metadataTemplate)
  return uploadedMetadata
}

module.exports = { uploadimages, setTokenMetaData }
