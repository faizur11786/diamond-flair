/* global ethers */
/* eslint prefer-const: "off" */

const { ethers } = require("hardhat");
const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function deployDiamond() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    const diamondAddress = "0x529aca21B345c84fEFF18192b37d4B2e12793093";
    const diamond = await ethers.getContractAt("Marketplace", diamondAddress);
    const token = await ethers.getContractAt(
        "SokosERC721",
        "0x3cEa35CAb8485e29D19672c3e23f65387C7606BC"
    );
    let tx;
    let receipt;

    // tx = await diamond.createListing(
    //     "0xe8e66e1D94F5AB0E236BF721aD2C9676d433db91",
    //     "0x3cEa35CAb8485e29D19672c3e23f65387C7606BC",
    //     "1",
    //     "1",
    //     "1000000"
    // );
    // tx = await token.mint(
    //     contractOwner.address,
    //     "TTS",
    //     "0",
    //     ethers.constants.AddressZero
    // );
    // tx = await token.setApprovalForAll(diamondAddress, true);
    // tx = await diamond.offer(
    //     "0x5d0CdCAd2276a31A3F7E9445a4b36F682784E573",
    //     "0",
    //     "10000",
    //     "1693302404"
    // );

    // tx = await diamond.cancelOffer("1");

    // console.log("tx: ", tx);
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Failed: ${tx.hash}`);
    // }
    // console.log("Completed", receipt);
    console.log("tx: ", await diamond.offerOf(contractOwner.address, "2"));
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
