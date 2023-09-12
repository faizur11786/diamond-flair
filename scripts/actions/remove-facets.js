/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("./../libraries/diamond.js");

async function erc20Token() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const diamondAddress = "0xf09afD66F7302BD73CA3b3fb952C0926433C6936";

    const FacetNames = [
        // {
        //     name: "ERC2771Context",
        //     address: "0x66Bae5FA07dF82F3fAaae200001D8D53bf165E37",
        // },
        // {
        //     name: "ERC2771ContextOwnable",
        //     address: "0x9E0eECe3FE00dD5620360C50b8e359aC8B090881",
        // },
        // {
        //     name: "MarketplaceBaseOwnable",
        //     address: "0x19a01fFbb9C6B2358E9a9b1E5938174bd5e7E267",
        // },
        // {
        //     name: "Marketplace",
        //     address: "0xDF6ba301cefD18a28033F96BBD801Da69C36C636",
        // },
        {
            name: "Marketplace",
            address: "0x6A11F53B3026a756F77b0caaAA5caA92d4a12Ca4",
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
            action: FacetCutAction.Remove,
            functionSelectors: getSelectors(facet).get([
                "offer(address,uint256)",
            ]),
            // .get([
            //     "collections()",
            //     // "createERC1155Collection(string,string,string,address)",
            //     // "createListing(address,uint256,uint256,uint256,uint256,uint256)",
            //     // "getListingId(address,address,uint256)",
            //     // "cancelListing(address,uint256)",
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
