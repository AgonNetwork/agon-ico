var AgonToken = artifacts.require("./AgonToken.sol");

module.exports = function(deployer) {
    deployer.deploy(AgonToken);
};