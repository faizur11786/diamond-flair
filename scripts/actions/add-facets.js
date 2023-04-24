/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("../libraries/diamond.js");

async function erc20Token() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const diamondAddress = "0x9F7af917573DB7A510fE54e521CBE779EeFF3d2F";

    const FacetNames = [
        {
            name: "ERC2771Context",
            address: "0x4C97989Ea3b7f3DC40b64183cCA0E734c08D5DD8",
        },
        {
            name: "ERC2771ContextOwnable",
            address: "0xbC65911F3b6BeF213685FF68d8095A6135d1C97e",
        },
        {
            name: "Marketplace",
            address: "0x5aa004567D3fb70DfcDC93c611808032a3C28d7a",
        },
        {
            name: "MarketplaceBaseOwnable",
            address: "0x0Da76127b3C788759C88878E520e84BB0D87b61b",
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

    // diamondCut
    const diamondCut = await ethers.getContractAt(
        "IDiamondCut",
        diamondAddress
    );
    let tx;
    let receipt;
    const gasPrice = ethers.utils.parseUnits("226.9", "gwei");

    tx = await diamondCut.diamondCut(cut, ethers.constants.AddressZero, "0x", {
        // gasPrice: gasPrice,
        // gasLimit: 1000000,
    });
    console.log("Diamond cut tx: ", tx.hash);
    receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }
    console.log("Completed diamond cut");
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
