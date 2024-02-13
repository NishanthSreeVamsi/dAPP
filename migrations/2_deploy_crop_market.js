// File: migrations/2_deploy_crop_market.js
const CropMarket = artifacts.require("CropMarket");

module.exports = function (deployer) {
  deployer.deploy(CropMarket);
};
