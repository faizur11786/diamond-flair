/* global ethers task */
// require('@nomiclabs/hardhat-waffle')
require("@openzeppelin/hardhat-upgrades");
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
    const accounts = await ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: {
        version: "0.8.15",
        settings: {
            optimizer: {
                enabled: true,
                runs: 1,
            },
        },
    },
    networks: {
        mumbai: {
            url: "https://yolo-thrumming-shard.matic-testnet.discover.quiknode.pro/af4a94e9aba81a0d0bf8fe6c8922b680d49d01f4/",
            accounts: [`${process.env.PRIV_KEY}`, `${process.env.PRIV_KEY}`],
            chainId: 80001,
        },
        polygon: {
            url: "https://magical-wider-borough.matic.discover.quiknode.pro/10eeb2e2efd2fc42bc9413ddf4964b2d162828b8/",
            accounts: [`${process.env.PRIV_KEY}`],
            chainId: 137,
        },
        mumbaiOwner: {
            url: "https://yolo-thrumming-shard.matic-testnet.discover.quiknode.pro/af4a94e9aba81a0d0bf8fe6c8922b680d49d01f4/",
            accounts: [`${process.env.PRIV_KEY}`],
            chainId: 80001,
        },
        goerli: {
            url: "https://nd-719-675-074.p2pify.com/633210afb47eeb316abfc98e05db1dba",
            accounts: [`${process.env.PRIV_KEY2}`],
            chainId: 5,
        },
        ganache: {
            url: "http://127.0.0.1:7545/",
            accounts: [
                `0x1c15909cd5826b8885c28e8aeddc31a83b2497214f3c942ce29dab45ad7acd9e`,
            ],
            chainId: 1337,
        },
    },
    etherscan: {
        apiKey: {
            goerli: process.env.GORELI_API_KEY,
            polygonMumbai: process.env.ETHERSCAN_API_KEY,
            polygon: process.env.ETHERSCAN_API_KEY,
        },
    },
};
