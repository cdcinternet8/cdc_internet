const fs = require('fs');
const path = require('path');
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;
const CONFIG_PATH = path.join(__dirname, 'config.json');

app.use(cors());
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// Helper to read config
function readConfig() {
    try {
        if (!fs.existsSync(CONFIG_PATH)) {
            return null;
        }
        const data = fs.readFileSync(CONFIG_PATH, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error("Error reading config.json:", error);
        return null;
    }
}

// Helper to write config
function writeConfig(config) {
    try {
        fs.writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2), 'utf8');
        return true;
    } catch (error) {
        console.error("Error writing config.json:", error);
        return false;
    }
}

// GET /api/config (Public config - adminPin stripped for security)
app.get('/api/config', (req, res) => {
    const config = readConfig();
    if (!config) {
        return res.status(500).json({ error: "Failed to read configuration." });
    }
    // Clean clone to strip sensitive information
    const publicConfig = JSON.parse(JSON.stringify(config));
    if (publicConfig.settings) {
        delete publicConfig.settings.adminPin;
    }
    res.json(publicConfig);
});

// POST /api/admin/login (Verify PIN and return full configuration if valid)
app.post('/api/admin/login', (req, res) => {
    const reqPin = req.headers['x-admin-pin'] || req.body.pin;
    const config = readConfig();
    if (!config) {
        return res.status(500).json({ error: "Failed to read configuration." });
    }
    const storedPin = config.settings.adminPin || "admin123";
    if (reqPin === storedPin) {
        res.json(config);
    } else {
        res.status(401).json({ error: "Invalid PIN" });
    }
});

// POST /api/config (Authorized configuration saving)
app.post('/api/config', (req, res) => {
    const newConfig = req.body;
    const reqPin = req.headers['x-admin-pin'];

    const currentConfig = readConfig();
    if (!currentConfig) {
        return res.status(500).json({ error: "Failed to verify current configuration." });
    }

    const storedPin = currentConfig.settings.adminPin || "admin123";

    if (!reqPin || reqPin !== storedPin) {
        return res.status(401).json({ error: "Unauthorized access PIN." });
    }

    if (writeConfig(newConfig)) {
        res.json({ message: "Configuration updated successfully!", config: newConfig });
    } else {
        res.status(500).json({ error: "Failed to write configuration." });
    }
});

// Route fallback for /admin -> serves admin.html
app.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'admin.html'));
});

app.listen(PORT, () => {
    console.log(`CDC Internet Server running on port ${PORT}`);
});
