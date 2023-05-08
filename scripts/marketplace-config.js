/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function sokosMarketplaceConfig() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const diamondAddress = "0x658D7591FFC60b008c7Bf24632C1eb2062b7E4A5";
    const marketplace = await ethers.getContractAt(
        "MarketplaceBaseOwnable",
        diamondAddress
    );
    let tx, receipt;
    // setDecimals
    // tx = await marketplace.setDecimals("6");
    // console.log("Set Decimals hash", tx.hash);
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Set Decimals hash failed: ${tx.hash}`);
    // }

    // // setFee
    // tx = await marketplace.setFee((2 * 1e6).toString());
    // console.log("Set Fee hash", tx.hash);
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Set Fee hash failed: ${tx.hash}`);
    // }

    // // setFeeReceipient
    // tx = await marketplace.setFeeReceipient(contractOwner.address);
    // console.log("Set Fee Receipient hash", tx.hash);
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Set Fee Receipient hash failed: ${tx.hash}`);
    // }

    // setMintFee

    // addPayableToken
    tx = await marketplace.addPayableToken(
        "0xfa22C55711a4aED74E46ACfe4B171e02386444bf",
        "0x92C09849638959196E976289418e5973CC96d645",
        "18"
    );
    console.log("Add Payable Token hash", tx.hash);
    receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Add Payable Token hash failed: ${tx.hash}`);
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    sokosMarketplaceConfig()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

exports.sokosMarketplaceConfig = sokosMarketplaceConfig;
