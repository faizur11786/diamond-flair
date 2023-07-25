/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("../libraries/diamond.js");

async function erc20Token() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const diamondAddress = "0x1Ca513adea10d8bfA7e6eBe07b8e259e81Ad095d";

    const FacetNames = [
        // {
        //     name: "ERC2771Context",
        //     address: "0x3E0A467A4F8AfBe508b9d674A7d2204698C316f1",
        // },
        // {
        //     name: "ERC2771ContextOwnable",
        //     address: "0xFD2C3204fca9B59119c18AEaAa9d0dc3e2B6a9D0",
        // },
        // {
        //     name: "MarketplaceBaseOwnable",
        //     address: "0x5580b328a9e3cEf94d87234CD65934c256A0E1F5",
        // },
        {
            name: "Marketplace",
            address: null,
        },
        // {
        //     name: "Factory",
        //     address: null,
        // },
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
            functionSelectors: getSelectors(facet).get([
                // "cancelListing(address,uint256)",
                // "getListingId(address,address,uint256)",
                "createListing(address,uint256,uint256,uint256,uint256,uint256)",
            ]),
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
