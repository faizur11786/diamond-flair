/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function erc20Token() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const diamondAddress = "0xC68370956A07471882290ad82281C3e6E3014532";

    const FacetNames = [
        {
            name: "SokosERC721A",
            address: "0xa030ccA0e4f14f62b6f23A0448f58e4A8AB6C05E",
        },
        {
            name: "ERC721Metadata",
            address: "0x1D8d7D162DA021B8D61B32ED9d7ee368f807d30E",
        },
        {
            name: "ERC721SupplyOwnable",
            address: "0x86296E032C71ec69c9E5c1DDA497098f91d1F76f",
        },
        {
            name: "ERC721MintableOwnableERC2771",
            address: "0xEf95fc84677e86554C4a23bd34a8dDa0986FA7b9",
        },
        {
            name: "ERC721LockableOwnable",
            address: "0xF8F9a17cdE74FFc1eaAbC7A0b515e3124B46E346",
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
