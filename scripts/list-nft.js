/* global ethers */
/* eslint prefer-const: "off" */

const { ethers } = require("hardhat");
const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function deployDiamond() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    const diamondAddress = "0x529aca21B345c84fEFF18192b37d4B2e12793093";
    const marketplace = await ethers.getContractAt(
        "Marketplace",
        diamondAddress
    );

    let tx;
    let receipt;
    tx = await marketplace.createListing(
        "0xe8e66e1D94F5AB0E236BF721aD2C9676d433db91",
        "0xb778BA02ac918d4FBBDE007574999F0EB64f48b0",
        "2",
        "1",
        "1000000"
    );
    console.log("tx: ", tx);
    receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Failed: ${tx.hash}`);
    }
    console.log("Completed", receipt);
    console.log("Completed", await marketplace.listingIds());
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
