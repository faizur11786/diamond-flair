/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("../libraries/diamond.js");

async function erc20Token() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const diamondAddress = "0xA69c8e5436e6e754caE03A64cc14d39c94a05Ec8";

    const FacetNames = [
        {
            name: "ERC2771Context",
            address: "0xac68df9c24181EB3d1B4AF229369504Cb2943Aef",
        },
        {
            name: "ERC2771ContextOwnable",
            address: "0x43e24477247DF68304B7Ef3ee03CA21196A8F06a",
        },
        {
            name: "Marketplace",
            address: "0x1A83eD4a9E8dc9430C60c1F8b838a5e766f94C49",
        },
        {
            name: "MarketplaceBaseOwnable",
            address: "0x90B853BA15beaFf09D0057767D4EB8D4C223A1E3",
        },
        {
            name: "Factory",
            address: "0x36694906D649dE9BD473501ED9E4AE9c0309A2bd",
        },
        {
            name: "TransferERC2771",
            address: "0x95B18C2Fe2982f73ed93725690F8c87835110c66",
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
            // .get([
            //     "createERC721Collection(string,string,string,address)",
            //     // "createERC1155Collection(string,string,string,address)",
            //     // "cancelListing(address,uint256)",
            //     // "getListingId(address,address,uint256)",
            //     // "createListing(address,uint256,uint256,uint256,uint256,uint256)",
            // ]),
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
    const gasPrice = ethers.utils.parseUnits("200", "gwei");

    tx = await diamondCut.diamondCut(cut, ethers.constants.AddressZero, "0x");
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
