/* global ethers */
/* eslint prefer-const: "off" */

const { default: axios } = require("axios");
const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

// Import Moralis
const Moralis = require("moralis").default;
// Import the EvmChain dataType
const { EvmChain } = require("@moralisweb3/common-evm-utils");

const TOKEN_IPFS_CIDS = {
    1: "QmZ8Syn28bEhZJKYeZCxUTM5Ut74ccKKDbQCqk5AuYsEnp",
    2: "QmZVpSsjvxev3C8Dv4E44fSp8gGMP6aoLMp56HmZi5Wkxh",
    3: "QmZMo8JDB9isA7k7tr8sFLXYwNJNa51XjJinkLWcc9vnta",
    4: "QmV7fqfJBozrc7VtaHSd64GvwNYqoQE1QptaysenTJrbpL",
    5: "QmSK1Zr6u2f2b8VgaFgz9CY1NR3JEyygQPQjJZaAA496Bh",
    6: "QmafTK2uFRuLyir2zJpLSBMercq2nDfxtSiMWXL1dbqTDn",
    7: "QmXTMYJ3rKeTCaQ79QQPe2EYcpVFbHr3maqJCPGcUobS4B",
    8: "QmQa97BYq9se73AztVF4xG52fGSBVB1kZKtAtuhYLHE1NA",
};
const TOKEN_URI = "https://ipfs.unique.network/ipfs/" + TOKEN_IPFS_CIDS["2"];

async function sokosMarketplaceConfig() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const diamondAddress = "0x658D7591FFC60b008c7Bf24632C1eb2062b7E4A5";
    const marketplace = await ethers.getContractAt(
        "Marketplace",
        diamondAddress
    );

    await Moralis.start({
        apiKey: process.env.MORALIS_KEY,
    });

    // Get the nfts
    const nftsBalances = await Moralis.EvmApi.nft.getWalletNFTs({
        address: contractOwner.address,
        chain: "80001",
        limit: 5,
    });
    // Format the output to return name, amount and metadata
    const nfts = nftsBalances.result.map((nft) => ({
        name: nft.result.name,
        amount: nft.result.amount,
        metadata: nft.result.metadata,
        tokenAddress: nft.result.tokenAddress._value,
        ownerOf: nft.result.ownerOf._value,
        contractType: nft.result.contractType,
        tokenId: nft.result.tokenId,
    }));

    const _isApprovedForAll = async (token, owner) => {
        return await token.isApprovedForAll(owner, marketplace.address);
    };
    let tx, receipt;

    // for (let i = 0; i < nfts.length; i++) {
    const nft = nfts[1];
    console.log("nft", nft);
    const { data: abi } = await axios.get(
        `https://raw.githubusercontent.com/webaverse/app/master/${
            nft.contractType === "ERC1155" ? "erc1155" : "erc721"
        }-abi.json`
    );
    const token = await ethers.getContractAt(abi, nft.tokenAddress);
    if (!(await _isApprovedForAll(token, nft.ownerOf))) {
        console.log("Approving...");
        tx = await token.setApprovalForAll(marketplace.address, true);
        console.log("Set Approval For All hash", tx.hash);
        await tx.wait();
        console.log("Approval Done");
    }
    const startTime = Math.floor(new Date().getTime() / 1000 + 15);
    const endTime = Math.floor(new Date().getTime() / 1000 + 3 * 24 * 60 * 60);

    tx = await marketplace.createListing(
        token.address,
        nft.tokenId,
        1,
        (10 * 1e6).toString(),
        startTime.toString(),
        endTime.toString()
    );
    console.log(await tx.wait());
    // }

    // token: 0xCC6D6F15c3fffc3e4825bc528AFdC5514c84AD52
    // tokenId: 3

    // console.log("Add Payable Token hash", tx.hash);
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Add Payable Token hash failed: ${tx.hash}`);
    // }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    sokosMarketplaceConfig()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

exports.sokosMarketplaceConfig = sokosMarketplaceConfig;
