/* global describe it before ethers */

const {
    getSelectors,
    FacetCutAction,
    removeSelectors,
    findAddressPositionInFacets,
} = require("../scripts/libraries/diamond.js");

const { deployDiamond } = require("../scripts/deploy.js");

const { assert } = require("chai");

describe("DiamondTest", async function () {
    let marketplace;
    let tx;
    let receipt;
    let result;
    const addresses = [];

    before(async function () {
        const diamondAddress = "0x658D7591FFC60b008c7Bf24632C1eb2062b7E4A5";
        marketplace = await ethers.getContractAt("Marketplace", diamondAddress);
    });

    it("should have three facets -- call to facetAddresses function", async () => {
        console.log("marketplace", marketplace);
        // for (const address of await diamondLoupeFacet.facetAddresses()) {
        //     addresses.push(address);
        // }
        // assert.equal(addresses.length, 3);
    });
});
