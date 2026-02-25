const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const path = require("path");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Serve frontend (VERY IMPORTANT for EC2)
app.use(express.static(path.join(__dirname, "../frontend")));

app.post("/contact", (req, res) => {
    const { name, email, subject, message } = req.body;

    console.log("New Contact Request:");
    console.log(name, email, subject, message);

    res.json({
        status: "success",
        message: "Message received successfully!"
    });
});

// Fallback route
app.get("*", (req, res) => {
    res.sendFile(path.join(__dirname, "../frontend/index.html"));
});

const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
