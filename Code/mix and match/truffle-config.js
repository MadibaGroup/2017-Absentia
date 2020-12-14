
module.exports = {
  

  networks: {
  
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
     gasPrice: 97000000000, 
     gasLimit: 12414689,
     gas: 12414689,           // Gas sent with each transaction (default: ~6700000) 1000000000  12414689 97 gwei price 
     //prev val :1000000000

    },

  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.5.12",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: true,
         runs: 20 //200 before
       },
       evmVersion: "byzantium"
      }
    }
  }
}


// module.exports = {
//   networks: {
//     development: {
//       host: "127.0.0.1",
//       port: 7545,
//       network_id: "*"
//     },
//     compilers: {
//       solc: {
//         version: "0.5.12",    // Fetch exact version from solc-bin (default: truffle's version)
//         // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
//         settings: {          // See the solidity docs for advice about optimization and evmVersion
//          optimizer: {
//            enabled: true,
//            runs: 200
//          },
//          evmVersion: "byzantium"
//         }
//       }
//     }
//   }
// };
