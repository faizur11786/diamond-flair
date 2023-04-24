/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function deployDiamond() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    // // deploy DiamondCut
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
    const ERC165 = await ethers.getContractFactory("ERC165");
    const erc165Facet = await ERC165.deploy();
    await erc165Facet.deployed();
    console.log("erc165Facet deployed:", erc165Facet.address);

    // deploy Ownable
    const Ownable = await ethers.getContractFactory("Ownable");
    const erc173Facet = await Ownable.deploy();
    await erc173Facet.deployed();
    console.log("erc173Facet deployed:", erc173Facet.address);

    console.log("sdfsd", {
        diamondCutFacet: diamondCutFacet.address,
        diamondLoupeFacet: diamondLoupeFacet.address,
        erc165Facet: erc165Facet.address,
        erc173Facet: erc173Facet.address,
    });

    // deploy Diamond
    const Diamond = await ethers.getContractFactory("SokosDiamond");
    const diamond = await Diamond.deploy(
        contractOwner.address,
        {
            diamondCutFacet: diamondCutFacet.address,
            diamondLoupeFacet: diamondLoupeFacet.address,
            erc165Facet: erc165Facet.address,
            erc173Facet: erc173Facet.address,
        },
        [],
        []
    );
    await diamond.deployed();
    console.log("Diamond deployed:", diamond.address);

    const FacetNames = [
        {
            name: "ERC2771Context",
            address: null,
        },
        {
            name: "ERC2771ContextOwnable",
            address: null,
        },
        {
            name: "Marketplace",
            address: null,
        },
        {
            name: "MarketplaceBaseOwnable",
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
