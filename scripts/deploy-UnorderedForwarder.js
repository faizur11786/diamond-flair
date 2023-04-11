/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function erc20Token() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const diamondAddress = "0x08291Db3878428d6A0B399adBc64854D0aDa8861";

    const FacetNames = [
        {
            name: "UnorderedForwarder",
            address: null,
        },
    ];
    const cut = [];
    for (const FacetName of FacetNames) {
        let facet;
        if (!FacetName.address) {
            const Facet = await ethers.getContractFactory(FacetName.name);
            facet = await Facet.deploy();
            await facet.deployed();
            console.log(`${FacetName.name} deployed: ${facet.address}`);
        } else {
            facet = await ethers.getContractAt(
                FacetName.name,
                FacetName.address
            );
        }

        cut.push({
            facetAddress: facet.address,
            action: FacetCutAction.Add,
            functionSelectors: getSelectors(facet),
        });
    }
    console.log("Cut", cut);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    erc20Token()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

exports.erc20Token = erc20Token;
