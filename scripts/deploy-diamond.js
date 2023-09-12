/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function deployDiamond() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    // deploy DiamondCut
    const DiamondCut = await ethers.getContractFactory("DiamondCut");
    const diamondCutFacet = await DiamondCut.deploy();
    await diamondCutFacet.deployed();
    console.log("diamondCutFacet deployed:", diamondCutFacet.address);

    // deploy DiamondLoupe
    const DiamondLoupe = await ethers.getContractFactory("DiamondLoupe");
    const diamondLoupeFacet = await DiamondLoupe.deploy();
    await diamondLoupeFacet.deployed();
    console.log("diamondLoupeFacet deployed:", diamondLoupeFacet.address);

    // deploy ERC165
    const ERC165 = await ethers.getContractFactory("ERC165Facet");
    const erc165Facet = await ERC165.deploy();
    await erc165Facet.deployed();
    console.log("erc165Facet deployed:", erc165Facet.address);

    // deploy Ownable
    const Ownable = await ethers.getContractFactory("OwnableFacet");
    const erc173Facet = await Ownable.deploy();
    await erc173Facet.deployed();
    console.log("erc173Facet deployed:", erc173Facet.address);

    console.log("Facets", {
        diamondCutFacet: "0x481Aa444752b658DA3F19116C736f0c5006aCF7e",
        diamondLoupeFacet: "0x49b42BA1cFB390D42888CF6Cb3b75460662A25DA",
        erc165Facet: "0xD8073e8F3FAc5aDDD5DB7EbaEC7F0af0D8B1d57a",
        erc173Facet: "0xB92e18540cc14920C6BE8961F89ec53558a49a6E",
    });

    // deploy Diamond
    const Diamond = await ethers.getContractFactory("SokosDiamond");
    const diamond = await Diamond.deploy(
        contractOwner.address,
        {
            diamondCutFacet: "0x481Aa444752b658DA3F19116C736f0c5006aCF7e",
            diamondLoupeFacet: "0x49b42BA1cFB390D42888CF6Cb3b75460662A25DA",
            erc165Facet: "0xD8073e8F3FAc5aDDD5DB7EbaEC7F0af0D8B1d57a",
            erc173Facet: "0xB92e18540cc14920C6BE8961F89ec53558a49a6E",
        },
        [],
        []
    );
    await diamond.deployed();
    console.log("Diamond deployed:", diamond.address);

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

    // diamondCut
    const diamondCut = await ethers.getContractAt(
        "IDiamondCut",
        diamond.address
    );
    let tx;
    let receipt;
    // const gasPrice = ethers.utils.parseUnits("132", "gwei");

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
    deployDiamond()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

exports.deployDiamond = deployDiamond;
