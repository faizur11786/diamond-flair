/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("../libraries/diamond.js");

async function erc20Token() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const diamondAddress = "0x4E5f019acab52097af2fFB28550EE6f84673Ce6b";

    const FacetNames = [
        {
            name: "SokosToken",
            address: "0x19EB979c0045561fe00D59E5947D879B70509f9a",
        },
        {
            name: "ERC20Metadata",
            address: "0xA2A4eAbaaDd9272D18e85CCA660824F89e1a99e8",
        },
        {
            name: "ERC20MetadataOwnable",
            address: "0x19cC6B4563870Aa22a8F2ccBAD5875fb85240094",
        },
        {
            name: "ERC20SupplyOwnable",
            address: "0xA5B0eE674fB78A7191608e2DFE7737CB7e4a4aFE",
        },
        {
            name: "ERC20MintableOwnableERC2771",
            address: "0x014056C6BCb6B842ad2FBEcd28c58D50f7950029",
        },
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
