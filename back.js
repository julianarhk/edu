const express = require("express");
const Web3 = require("web3");
const { MongoClient } = require("mongodb");
const { abi: contractAbi } = require("./EduCollectNFT.json");

const app = express();
const port = 3000;

const mongoURI = "mongodb://localhost:27017/educollect";
const client = new MongoClient(mongoURI);

async function run() {
   try {
       await client.connect();
       console.log("Connected to MongoDB");

       const web3Provider = new Web3.providers.HttpProvider("https://mainnet.infura.io/v3/YOUR_INFURA_API_KEY");
       const web3 = new Web3(web3Provider);

       const contractAddress = "0xYOUR_CONTRACT_ADDRESS";
       const contract = new web3.eth.Contract(contractAbi, contractAddress);

       app.use(express.json());

       app.post("/mint-badge", async (req, res) => {
           try {
               const { recipient, name, description, imageUrl } = req.body;

               const mintedBadgeId = await contract.methods
                   .mintBadge(recipient, name, description, imageUrl)
                   .send({ from: "0xYOUR_ADMIN_ADDRESS" });

               const badgeData = {
                   badgeId: mintedBadgeId,
                   name,
                   description,
                   imageUrl,
                   owner: recipient,
               };
               await client.db().collection("badges").insertOne(badgeData);

               res.status(200).json({ success: true, badgeId: mintedBadgeId });
           } catch (error) {
               console.error(error);
               res.status(500).json({ success: false, error: "Failed to mint a badge" });
           }
       });

   app.get("/badge-owner/:badgeId", async (req, res) => {
    try {
        const { badgeId } = req.params;

        const badgeData = await client.db().collection("badges").findOne({ badgeId });
        if (!badgeData) {
            res.status(404).json({ success: false, error: "Badge not found" });
            return;
        }

        res.status(200).json({ success: true, owner: badgeData.owner });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, error: "Failed to get badge owner" });
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});

}

run().catch((error) => {
    console.error(error);
    process.exit(1);
});