/* global ethers */
/* eslint prefer-const: "off" */

const { ethers } = require("hardhat");
const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function deployDiamond() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    const diamondAddress = "0xA69c8e5436e6e754caE03A64cc14d39c94a05Ec8";
    const diamond = await ethers.getContractAt("Marketplace", diamondAddress);
    let tx;
    let receipt;

    // tx = await diamond.cancelOffer("1");

    // console.log("tx: ", tx);
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Failed: ${tx.hash}`);
    // }
    // console.log("Completed", receipt);
    console.log("tx: ", await diamond.decimals());
    return;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    deployDiamond()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

exports.deployDiamond = deployDiamond;
