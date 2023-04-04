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
    const Diamond = await ethers.getContractFactory("Diamond");
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

    // // deploy DiamondInit
    // // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
    // // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
    // const DiamondInit = await ethers.getContractFactory('DiamondInit')
    // const diamondInit = await DiamondInit.deploy()
    // await diamondInit.deployed()
    // console.log('DiamondInit deployed:', diamondInit.address)

    // // deploy facets
    // console.log('')
    // console.log('Deploying facets')
    // const FacetNames = [
    //   'DiamondLoupeFacet',
    //   'OwnershipFacet'
    // ]
    // const cut = []
    // for (const FacetName of FacetNames) {
    //   const Facet = await ethers.getContractFactory(FacetName)
    //   const facet = await Facet.deploy()
    //   await facet.deployed()
    //   console.log(`${FacetName} deployed: ${facet.address}`)
    //   cut.push({
    //     facetAddress: facet.address,
    //     action: FacetCutAction.Add,
    //     functionSelectors: getSelectors(facet)
    //   })
    // }

    // // upgrade diamond with facets
    // console.log('')
    // console.log('Diamond Cut:', cut)
    // const diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address)
    // let tx
    // let receipt
    // // call to init function
    // let functionCall = diamondInit.interface.encodeFunctionData('init')
    // tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
    // console.log('Diamond cut tx: ', tx.hash)
    // receipt = await tx.wait()
    // if (!receipt.status) {
    //   throw Error(`Diamond upgrade failed: ${tx.hash}`)
    // }
    // console.log('Completed diamond cut')
    // return diamond.address
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
