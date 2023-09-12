/* global ethers */
/* eslint prefer-const: "off" */

const { ethers } = require("hardhat");
const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function deployDiamond() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    const diamondAddress = "0xA69c8e5436e6e754caE03A64cc14d39c94a05Ec8";
    const factory = await ethers.getContractAt("Factory", diamondAddress);

    // let tx;
    // let receipt;

    // tx = await factory.createERC721Collection(
    //     "x721",
    //     "XX",
    //     "uri",
    //     "0xab0fA70234858a5B044cdc4F44f0b1bfddf15e1A"
    // );
    // console.log("tx: ", tx);
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Failed: ${tx.hash}`);
    // }
    // console.log("Completed", receipt);
    console.log("Collections", await factory.collections());
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
