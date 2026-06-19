const fs = require('fs');
const path = require('path');
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;
const CONFIG_PATH = path.join(__dirname, 'config.json');

// ── CORS: allow any origin (Flutter app + browser admin panel) ──
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'X-Admin-PIN', 'Cache-Control'],
}));
app.use(bodyParser.json({ limit: '1mb' }));
app.use(express.static(path.join(__dirname, 'public')));

// ── In-memory config store (loaded once from config.json on startup) ──
// On Render free tier the filesystem is ephemeral but stays alive during
// a session, so in-memory is the reliable source of truth.
let inMemoryConfig = null;

function loadConfigFromDisk() {
    try {
        if (fs.existsSync(CONFIG_PATH)) {
            const data = fs.readFileSync(CONFIG_PATH, 'utf8');
            inMemoryConfig = JSON.parse(data);
            console.log('Config loaded from disk successfully.');
        } else {
            console.warn('config.json not found – using built-in defaults.');
            inMemoryConfig = getDefaultConfig();
        }
    } catch (err) {
        console.error('Error loading config.json:', err.message);
        inMemoryConfig = getDefaultConfig();
    }
}

function getDefaultConfig() {
    return {
        contacts: { WhatsApp: '8801576526757', helpline: '+8801576526757' },
        settings: {
            vatPercentage: 5,
            popularTag: 'Most Popular',
            adminPin: 'admin123',
            orderMsgTemplate: 'Hello CDC!\n👤 Name ⇒ {name}\n📞 Phone ⇒ {phone}\n📍 Dist ⇒ {district}\n📦 Pkg ⇒ {package}\n🏠 Addr ⇒ {address}',
            supportMsgTemplate: 'Support Help:\n👤 Name ⇒ {name}\n📞 Phone ⇒ {phone}\n📍 Dist ⇒ {district}\n🏠 Addr ⇒ {address}\n🛠️ Issue ⇒ {details}',
        },
        packages: [
            { id: '1', name: 'STARTER FUN', tag: 'Browsing ⇒ Joy', speed: '20 Mbps', price: 500, total: 525, isPopular: false, color: '#0ea5e9', btnColor: '#10b981', icon: 'fa-dove', vat: 5, isGlowing: false },
            { id: '2', name: 'SUPER FAST', tag: 'Stream ⇒ No Worry', speed: '30 Mbps', price: 700, total: 735, isPopular: false, icon: 'fa-bolt-lightning', color: '#64748b', btnColor: '#0ea5e9', vat: 5, isGlowing: false },
            { id: '3', name: 'POWER FUN', tag: 'Lag-free ⇒ Fun', speed: '40 Mbps', price: 800, total: 840, isPopular: true, color: '#f59e0b', btnColor: '#f97316', icon: 'fa-fire-flame-curved', vat: 5, isGlowing: true },
            { id: '4', name: 'BLAZING', tag: 'Power User ⇒ Delight', speed: '50 Mbps', price: 900, total: 945, isPopular: false, icon: 'fa-droplet', color: '#f43f5e', btnColor: '#ec4899', vat: 5, isGlowing: false },
            { id: '5', name: 'ULTIMATE JOY', tag: 'Unlimited ⇒ Joy', speed: '60 Mbps', price: 1000, total: 1050, isPopular: false, icon: 'fa-crown', color: '#8b5cf6', btnColor: '#8b5cf6', vat: 5, isGlowing: false },
        ],
    };
}

function saveConfigToDisk(config) {
    try {
        fs.writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2), 'utf8');
    } catch (err) {
        // On Render the disk write may fail silently — in-memory is the source of truth
        console.warn('Disk write failed (expected on Render):', err.message);
    }
}

// Load config at startup
loadConfigFromDisk();

// ── ROUTES ──────────────────────────────────────────────────────────

// Health check (for Render to confirm the service is alive)
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// GET /api/config – public config (adminPin stripped)
app.get('/api/config', (req, res) => {
    const publicConfig = JSON.parse(JSON.stringify(inMemoryConfig));
    if (publicConfig.settings) {
        delete publicConfig.settings.adminPin;
    }
    // Prevent any intermediate caching
    res.set('Cache-Control', 'no-store, no-cache, must-revalidate');
    res.set('Pragma', 'no-cache');
    res.set('Expires', '0');
    res.json(publicConfig);
});

// POST /api/admin/login – verify PIN and return full config
app.post('/api/admin/login', (req, res) => {
    const reqPin = req.headers['x-admin-pin'] || req.body.pin;
    const storedPin = inMemoryConfig.settings.adminPin || 'admin123';
    if (reqPin === storedPin) {
        res.json(inMemoryConfig);
    } else {
        res.status(401).json({ error: 'Invalid PIN' });
    }
});

// POST /api/config – authorized config save (updates in-memory + tries disk)
app.post('/api/config', (req, res) => {
    const newConfig = req.body;
    const reqPin = req.headers['x-admin-pin'];
    const storedPin = inMemoryConfig.settings.adminPin || 'admin123';

    if (!reqPin || reqPin !== storedPin) {
        return res.status(401).json({ error: 'Unauthorized: invalid admin PIN.' });
    }

    // Update in-memory immediately so next /api/config returns fresh data
    inMemoryConfig = newConfig;

    // Best-effort disk write (works locally, may be ephemeral on Render)
    saveConfigToDisk(newConfig);

    res.json({ message: 'Configuration updated successfully!', config: newConfig });
});

// Serve admin.html at /admin
app.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'admin.html'));
});

// 404 fallback
app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
});

app.listen(PORT, () => {
    console.log(`CDC Internet Server running on port ${PORT}`);
});
