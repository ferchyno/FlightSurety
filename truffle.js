var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat";

module.exports = {
  networks: {
    development: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "http://127.0.0.1:8545/", 0, 50);
      },
      network_id: '*',
      gas: 4500000
    }
    // development: {
    //   host: "127.0.0.1",
    //   port: 8545,
    //   network_id: "*", // Match any network id
    //   gas: 4500000,        // rinkeby has a lower block limit than mainnet
    //   // gasPrice: 10000000000
    // },
  },
  compilers: {
    solc: {
      version: "^0.4.24"
    }
  }
};