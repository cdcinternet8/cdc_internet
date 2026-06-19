import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CDC INTERNET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E40AF),
          primary: const Color(0xFF1E40AF),
          secondary: const Color(0xFFF59E0B),
          surface: const Color(0xFFF8FAFC),
        ),
        fontFamily: 'Outfit',
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        ),
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
          elevation: 2,
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ==========================================
// MODELS
// ==========================================

class PackagePlan {
  final String id;
  final String name;
  final String tag;
  final String speed;
  final int price;
  final int total;
  final bool isPopular;
  final String color;
  final String btnColor;
  final String icon;
  final int vat;
  final bool isGlowing;

  PackagePlan({
    required this.id,
    required this.name,
    required this.tag,
    required this.speed,
    required this.price,
    required this.total,
    required this.isPopular,
    required this.color,
    required this.btnColor,
    required this.icon,
    required this.vat,
    required this.isGlowing,
  });

  factory PackagePlan.fromJson(Map<String, dynamic> json) {
    return PackagePlan(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      tag: json['tag'] ?? '',
      speed: json['speed'] ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      isPopular: json['isPopular'] ?? false,
      color: json['color'] ?? '#1e40af',
      btnColor: json['btnColor'] ?? '#1e40af',
      icon: json['icon'] ?? 'fa-bolt',
      vat: (json['vat'] as num?)?.toInt() ?? 5,
      isGlowing: json['isGlowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tag': tag,
        'speed': speed,
        'price': price,
        'total': total,
        'isPopular': isPopular,
        'color': color,
        'btnColor': btnColor,
        'icon': icon,
        'vat': vat,
        'isGlowing': isGlowing,
      };
}

class AppConfig {
  final String whatsapp;
  final String helpline;
  final int vatPercentage;
  final String popularTag;
  final String adminPin;
  final String orderMsgTemplate;
  final String supportMsgTemplate;
  final List<PackagePlan> packages;

  AppConfig({
    required this.whatsapp,
    required this.helpline,
    required this.vatPercentage,
    required this.popularTag,
    required this.adminPin,
    required this.orderMsgTemplate,
    required this.supportMsgTemplate,
    required this.packages,
  });

  factory AppConfig.defaultConfig() {
    return AppConfig(
      whatsapp: '8801576526757',
      helpline: '+8801576526757',
      vatPercentage: 5,
      popularTag: 'Most Popular',
      adminPin: 'admin123',
      orderMsgTemplate:
          "Hello CDC!\n👤 Name ⇒ {name}\n📞 Phone ⇒ {phone}\n📍 Dist ⇒ {district}\n📦 Pkg ⇒ {package}\n🏠 Addr ⇒ {address}",
      supportMsgTemplate:
          "Support Help:\n👤 Name ⇒ {name}\n📞 Phone ⇒ {phone}\n📍 Dist ⇒ {district}\n🏠 Addr ⇒ {address}\n🛠️ Issue ⇒ {details}",
      packages: [
        PackagePlan(
            id: '1',
            name: 'STARTER FUN',
            tag: 'Browsing ⇒ Joy',
            speed: '20 Mbps',
            price: 500,
            total: 525,
            isPopular: false,
            color: '#0ea5e9',
            btnColor: '#10b981',
            icon: 'fa-dove',
            vat: 5,
            isGlowing: false),
        PackagePlan(
            id: '2',
            name: 'SUPER FAST',
            tag: 'Stream ⇒ No Worry',
            speed: '30 Mbps',
            price: 700,
            total: 735,
            isPopular: false,
            color: '#64748b',
            btnColor: '#0ea5e9',
            icon: 'fa-bolt-lightning',
            vat: 5,
            isGlowing: false),
        PackagePlan(
            id: '3',
            name: 'POWER FUN',
            tag: 'Lag-free ⇒ Fun',
            speed: '40 Mbps',
            price: 800,
            total: 840,
            isPopular: true,
            color: '#f59e0b',
            btnColor: '#f97316',
            icon: 'fa-fire-flame-curved',
            vat: 5,
            isGlowing: true),
        PackagePlan(
            id: '4',
            name: 'BLAZING',
            tag: 'Power User ⇒ Delight',
            speed: '50 Mbps',
            price: 900,
            total: 945,
            isPopular: false,
            color: '#f43f5e',
            btnColor: '#ec4899',
            icon: 'fa-droplet',
            vat: 5,
            isGlowing: false),
        PackagePlan(
            id: '5',
            name: 'ULTIMATE JOY',
            tag: 'Unlimited ⇒ Joy',
            speed: '60 Mbps',
            price: 1000,
            total: 1050,
            isPopular: false,
            color: '#8b5cf6',
            btnColor: '#8b5cf6',
            icon: 'fa-crown',
            vat: 5,
            isGlowing: false),
      ],
    );
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    var pkgsJson = json['packages'] as List? ?? [];
    List<PackagePlan> pkgs = pkgsJson.map((e) => PackagePlan.fromJson(e)).toList();

    var contacts = json['contacts'] as Map<String, dynamic>? ?? {};
    var settings = json['settings'] as Map<String, dynamic>? ?? {};

    return AppConfig(
      whatsapp: contacts['WhatsApp']?.toString() ?? '8801576526757',
      helpline: contacts['helpline']?.toString() ?? '+8801576526757',
      vatPercentage: (settings['vatPercentage'] as num?)?.toInt() ?? 5,
      popularTag: settings['popularTag']?.toString() ?? 'Most Popular',
      adminPin: settings['adminPin']?.toString() ?? 'admin123',
      orderMsgTemplate: settings['orderMsgTemplate']?.toString() ?? '',
      supportMsgTemplate: settings['supportMsgTemplate']?.toString() ?? '',
      packages: pkgs,
    );
  }

  Map<String, dynamic> toJson() => {
        'contacts': {
          'WhatsApp': whatsapp,
          'helpline': helpline,
        },
        'settings': {
          'vatPercentage': vatPercentage,
          'popularTag': popularTag,
          'adminPin': adminPin,
          'orderMsgTemplate': orderMsgTemplate,
          'supportMsgTemplate': supportMsgTemplate,
        },
        'packages': packages.map((e) => e.toJson()).toList(),
      };
}

// ==========================================
// CONFIGURATION SERVICE
// ==========================================

class ConfigService {
  static const String _apiUrlKey = 'cdc_api_base_url';
  static const String _configKey = 'cdc_cached_config';
  static const String defaultUrl = 'http://10.0.2.2:3000';

  static Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiUrlKey) ?? defaultUrl;
  }

  static Future<void> saveApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, url);
  }

  static Future<AppConfig> getCachedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_configKey);
    if (data == null) {
      return AppConfig.defaultConfig();
    }
    try {
      return AppConfig.fromJson(jsonDecode(data));
    } catch (e) {
      debugPrint("Error parsing cached config: $e");
      return AppConfig.defaultConfig();
    }
  }

  static Future<void> saveConfigCache(AppConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, jsonEncode(config.toJson()));
  }

  static Future<AppConfig> fetchConfigFromServer(String baseUrl) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/config'),
      headers: {'Cache-Control': 'no-cache, no-store'},
    ).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final newConfig = AppConfig.fromJson(parsed);
      await saveConfigCache(newConfig);
      return newConfig;
    } else {
      throw Exception('Server returned ${response.statusCode}');
    }
  }
}

// ==========================================
// CORE UI COORDINATOR
// ==========================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  AppConfig _config = AppConfig.defaultConfig();
  bool _isOnline = false;
  bool _isSyncing = false;
  String _currentApiUrl = ConfigService.defaultUrl;

  PackagePlan? _selectedPlan;

  int _tapCount = 0;
  Timer? _tapResetTimer;

  // Auto-refresh every 30 seconds while app is open
  Timer? _autoRefreshTimer;
  static const Duration _pollInterval = Duration(seconds: 30);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialSettings();
    _initConnectivityListener();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _tapResetTimer?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  // Re-fetch config when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed — syncing config from server.');
      _syncConfig(showOverlay: false);
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _autoRefreshTimer?.cancel();
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_pollInterval, (_) {
      if (_isOnline) {
        debugPrint('Auto-refreshing config from server...');
        _syncConfig(showOverlay: false);
      }
    });
  }

  bool _showSyncOverlay = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _scrollIsAtTop = true;
  double? _pointerDownY;
  bool _canTriggerRefresh = false;

  Future<void> _loadInitialSettings() async {
    final url = await ConfigService.getApiUrl();
    final cached = await ConfigService.getCachedConfig();
    setState(() {
      _currentApiUrl = url;
      _config = cached;
    });
    _syncConfig(showOverlay: false);
  }

  void _initConnectivityListener() {
    _connectivity.checkConnectivity().then(_updateStatus);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final isDisconnected = results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none);
    setState(() {
      _isOnline = !isDisconnected;
    });
    if (_isOnline) {
      _syncConfig(showOverlay: false);
    }
  }

  Future<void> _syncConfig({bool showOverlay = false}) async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
      _showSyncOverlay = showOverlay;
    });
    final startTime = DateTime.now();
    try {
      final fresh = await ConfigService.fetchConfigFromServer(_currentApiUrl);
      setState(() {
        _config = fresh;
        _isOnline = true;
      });
      debugPrint("Configuration synced successfully from server.");
    } catch (e) {
      debugPrint("Failed to sync config: $e. Running on cached config.");
    } finally {
      if (showOverlay) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        final remaining = 1500 - elapsed;
        if (remaining > 0) {
          await Future.delayed(Duration(milliseconds: remaining));
        }
      }
      setState(() {
        _isSyncing = false;
        _showSyncOverlay = false;
      });
    }
  }

  void _handleLogoTap() {
    _tapCount++;
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 2), () {
      _tapCount = 0;
    });

    if (_tapCount >= 5) {
      _tapCount = 0;
      _showAdminPinDialog();
    }
  }

  void _showAdminPinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text(
            'Endpoint Authorization Required',
            style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Admin PIN to customize application synchronization endpoint:',
                style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  hintText: '••••••',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            ),
            TextButton(
              onPressed: () {
                final entered = pinController.text.trim();
                Navigator.pop(context);
                if (entered == _config.adminPin) {
                  _openHiddenSettings();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid authorization clearance code.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Authorize', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E40AF))),
            ),
          ],
        );
      },
    );
  }

  void _openHiddenSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: HiddenSettingsPanel(
            currentUrl: _currentApiUrl,
            onSaved: (newUrl) async {
              await ConfigService.saveApiUrl(newUrl);
              setState(() {
                _currentApiUrl = newUrl;
              });
              _syncConfig(showOverlay: true);
            },
          ),
        );
      },
    );
  }

  void _navigateToOrder(PackagePlan plan) {
    setState(() {
      _selectedPlan = plan;
      _currentIndex = 4; // Navigate to Order tab
      _scrollIsAtTop = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: const Color(0xFF1E40AF).withValues(alpha: 0.05),
          title: GestureDetector(
            onTap: _handleLogoTap,
            child: const Text(
              'CDC INTERNET',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -1,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () => _syncConfig(showOverlay: true),
          color: const Color(0xFF1E40AF),
          backgroundColor: Colors.white,
          displacement: 20,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.depth == 0) {
                if (notification.metrics.pixels <= 0.0) {
                  _scrollIsAtTop = true;
                } else {
                  _scrollIsAtTop = false;
                }
              }
              return false;
            },
            child: Listener(
              onPointerDown: (PointerDownEvent event) {
                _pointerDownY = event.position.dy;
                _canTriggerRefresh = _scrollIsAtTop;
              },
              onPointerMove: (PointerMoveEvent event) {
                if (_pointerDownY == null || !_canTriggerRefresh || _isSyncing) return;

                final dragDistance = event.position.dy - _pointerDownY!;
                if (dragDistance > 120.0) {
                  _pointerDownY = null;
                  _canTriggerRefresh = false;
                  _refreshIndicatorKey.currentState?.show();
                }
              },
              onPointerUp: (PointerUpEvent event) {
                _pointerDownY = null;
                _canTriggerRefresh = false;
              },
              onPointerCancel: (PointerCancelEvent event) {
                _pointerDownY = null;
                _canTriggerRefresh = false;
              },
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  HomeTab(
                    onViewPlans: () => setState(() {
                      _currentIndex = 1;
                      _scrollIsAtTop = true;
                    }),
                    onViewCoverage: () => setState(() {
                      _currentIndex = 2;
                      _scrollIsAtTop = true;
                    }),
                    onViewSupport: () => setState(() {
                      _currentIndex = 3;
                      _scrollIsAtTop = true;
                    }),
                    isOnline: _isOnline,
                    onRefresh: () => _syncConfig(showOverlay: true),
                    showSyncOverlay: _showSyncOverlay,
                  ),
                  PlansTab(
                    packages: _config.packages,
                    popularTag: _config.popularTag,
                    vatPercentage: _config.vatPercentage,
                    onSelectPlan: _navigateToOrder,
                    showSyncOverlay: _showSyncOverlay,
                  ),
                  CoverageTab(
                    showSyncOverlay: _showSyncOverlay,
                  ),
                  SupportTab(
                    whatsappNum: _config.whatsapp,
                    helplineNum: _config.helpline,
                    supportTemplate: _config.supportMsgTemplate,
                    showSyncOverlay: _showSyncOverlay,
                  ),
                  OrderTab(
                    whatsappNum: _config.whatsapp,
                    orderTemplate: _config.orderMsgTemplate,
                    selectedPlan: _selectedPlan,
                    showSyncOverlay: _showSyncOverlay,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _currentIndex == 0
            ? null
            : BottomNavigationBar(
                currentIndex: _currentIndex > 3 ? 1 : _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                    _scrollIsAtTop = true;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF0F172A),
                unselectedItemColor: const Color(0xFF64748B),
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_max_rounded),
                    label: 'DASHBOARD',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.speed_rounded),
                    label: 'PLANS',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map_rounded),
                    label: 'COVERAGE',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.support_agent_rounded),
                    label: 'SUPPORT',
                  ),
                ],
              ),
      ),
    );
  }
}

// ==========================================
// HIDDEN SETTINGS PANEL (BOTTOM SHEET)
// ==========================================

class HiddenSettingsPanel extends StatefulWidget {
  final String currentUrl;
  final Function(String) onSaved;

  const HiddenSettingsPanel({
    super.key,
    required this.currentUrl,
    required this.onSaved,
  });

  @override
  State<HiddenSettingsPanel> createState() => _HiddenSettingsPanelState();
}

class _HiddenSettingsPanelState extends State<HiddenSettingsPanel> {
  late final TextEditingController _urlController;
  bool _testingConnection = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final entered = _urlController.text.trim();
    if (entered.isEmpty) return;

    setState(() {
      _testingConnection = true;
      _testResult = null;
    });

    try {
      final response = await http.get(Uri.parse('$entered/api/config')).timeout(
            const Duration(seconds: 4),
          );
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed != null && parsed['packages'] != null) {
          setState(() {
            _testSuccess = true;
            _testResult = 'Endpoint connection verified! Setup synced.';
          });
        } else {
          setState(() {
            _testSuccess = false;
            _testResult = 'Server responded but config payload is invalid.';
          });
        }
      } else {
        setState(() {
          _testSuccess = false;
          _testResult = 'Server returned error status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _testSuccess = false;
        _testResult = 'Endpoint unreachable: $e';
      });
    } finally {
      setState(() {
        _testingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Endpoint Configuration',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Color(0xFF0F172A),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure the backend synchronization URL for the dynamic system:',
            style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'API BASE URL',
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_testResult != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _testSuccess ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _testSuccess ? const Color(0xFF10B981).withValues(alpha: 0.2) : const Color(0xFF1E40AF).withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                _testResult!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: _testSuccess ? const Color(0xFF065F46) : const Color(0xFF9F1239),
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _testingConnection ? null : _testConnection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: _testingConnection
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                  )
                : const Text('Test Connection Endpoint', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final newUrl = _urlController.text.trim();
              if (newUrl.isNotEmpty) {
                widget.onSaved(newUrl);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Endpoint configured successfully!'),
                    backgroundColor: Color(0xFF1E40AF),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 4,
              shadowColor: const Color(0xFF1E40AF).withValues(alpha: 0.2),
            ),
            child: const Text('SAVE ENDPOINT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ==========================================
// HOME TAB (PREMIUM DASHBOARD INTERFACE)
// ==========================================

class HomeTab extends StatelessWidget {
  final VoidCallback onViewPlans;
  final VoidCallback onViewCoverage;
  final VoidCallback onViewSupport;
  final bool isOnline;
  final Future<void> Function() onRefresh;
  final bool showSyncOverlay;

  const HomeTab({
    super.key,
    required this.onViewPlans,
    required this.onViewCoverage,
    required this.onViewSupport,
    required this.isOnline,
    required this.onRefresh,
    this.showSyncOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEFF6FF), // Soft premium cyan-blue
            Colors.white,      // Clean mid point
            Color(0xFFF1F5F9), // Soft dark gray-ish base
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand Promo Hero Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A), // deep blue
                    Color(0xFF1E40AF), // royal blue
                    Color(0xFF3B82F6), // vibrant blue
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                      children: [
                        TextSpan(
                          text: "Bangladesh's ",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: "#1",
                          style: TextStyle(color: Color(0xFFF59E0B)), // warm gold
                        ),
                        TextSpan(
                          text: "\nNationwide Internet",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'দেশজুড়ে আলোর গতি – মজা শুরু হয় এখান থেকে!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE2E8F0), // light silver grey
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Horizontal divider
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 14),
                  // Badges/Specs
                  const Text(
                    'Unlimited Fiber  •  20-60 Mbps  •  Free Installation  •  24/7 Support',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF59E0B), // light blue accent
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Navigation Tiles Row
            Row(
              children: [
                Expanded(
                  child: QuickActionTile(
                    icon: Icons.bolt_rounded,
                    label: 'Plans',
                    onTap: onViewPlans,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionTile(
                    icon: Icons.map_rounded,
                    label: 'Coverage',
                    onTap: onViewCoverage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionTile(
                    icon: Icons.support_agent_rounded,
                    label: 'Support',
                    onTap: onViewSupport,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Features List Header
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF1E40AF).withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E40AF).withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Why CDC is More Fun',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF1E40AF),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6 features in a 2-column layout (avoiding aspect ratio clip bugs)
            const Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FeatureCard(
                        leadingIcon: Icons.sports_esports_rounded,
                        leadingIconColor: Color(0xFFF43F5E),
                        leadingBgColor: Color(0xFFFFF1F2),
                        titleIcon: Icons.sports_esports_rounded,
                        titleIconColor: Color(0xFF4F46E5),
                        title: 'No Lag Gaming',
                        desc: 'Play Valorant, PUBG & Free Fire with low latency!',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: FeatureCard(
                        leadingIcon: Icons.local_movies_rounded,
                        leadingIconColor: Color(0xFFFB7185),
                        leadingBgColor: Color(0xFFFFF1F2),
                        titleIcon: Icons.movie_filter_rounded,
                        titleIconColor: Color(0xFFEAB308),
                        title: 'Movie Nights',
                        desc: '4K Netflix & YouTube — no spinning wheel!',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FeatureCard(
                        leadingIcon: Icons.menu_book_rounded,
                        leadingIconColor: Color(0xFF22C55E),
                        leadingBgColor: Color(0xFFF0FDF4),
                        titleIcon: Icons.school_rounded,
                        titleIconColor: Color(0xFF16A34A),
                        title: 'Homework',
                        desc: 'Online classes, Zoom calls & research — smooth!',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: FeatureCard(
                        leadingIcon: Icons.security_rounded,
                        leadingIconColor: Color(0xFFF97316),
                        leadingBgColor: Color(0xFFFFF7ED),
                        titleIcon: Icons.card_giftcard_rounded,
                        titleIconColor: Color(0xFFEA580C),
                        title: 'Free Setup',
                        desc: 'Zero setup cost. We come, we install, you smile.',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FeatureCard(
                        leadingIcon: Icons.handyman_rounded,
                        leadingIconColor: Color(0xFFA855F7),
                        leadingBgColor: Color(0xFFFAF5FF),
                        titleIcon: Icons.security_rounded,
                        titleIconColor: Color(0xFF7C3AED),
                        title: '24/7 Support',
                        desc: "Call us at 2 AM — we'll answer in minutes.",
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: FeatureCard(
                        leadingIcon: Icons.sentiment_satisfied_alt_rounded,
                        leadingIconColor: Color(0xFFEAB308),
                        leadingBgColor: Color(0xFFFEF3C7),
                        titleIcon: Icons.light_mode_rounded,
                        titleIconColor: Color(0xFFCA8A04),
                        title: 'BD Pure Joy',
                        desc: 'Built for Bangladesh, loved by 64 districts.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
        if (showSyncOverlay)
          Positioned.fill(
            child: FullPageSyncOverlay(
              isVisible: showSyncOverlay,
              type: SyncOverlayType.home,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            ),
          ),
      ],
    );
  }
}

class PromoHeroCard extends StatefulWidget {
  final VoidCallback onTap;

  const PromoHeroCard({super.key, required this.onTap});

  @override
  State<PromoHeroCard> createState() => _PromoHeroCardState();
}

class _PromoHeroCardState extends State<PromoHeroCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E40AF).withValues(alpha: 0.08),
                blurRadius: 28,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── White typography header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 33,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          height: 1.08,
                        ),
                        children: [
                          TextSpan(
                            text: "Bangladesh's ",
                            style: TextStyle(color: Color(0xFF0F172A)),
                          ),
                          TextSpan(
                            text: "#1",
                            style: TextStyle(color: Color(0xFF1E40AF)),
                          ),
                          TextSpan(
                            text: " Nationwide",
                            style: TextStyle(color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Internet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 33,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1.08,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'দেশজুড়ে আলোর গতি – মজা শুরু হয় এখান থেকে!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Blue gradient info block ──
              Container(
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF1E40AF),
                      Color(0xFF3B82F6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CDC Ultra-Fiber Gigabit',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'সীমাহীন ইন্টারনেট, সর্বোচ্চ গতি',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _SpecChip(label: '60 Mbps'),
                        const SizedBox(width: 8),
                        _SpecChip(label: 'Unlimited'),
                        const SizedBox(width: 8),
                        _SpecChip(label: 'Free Setup'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final String label;
  const _SpecChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class QuickActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E40AF).withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: const Color(0xFF1E40AF), size: 26),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final IconData leadingIcon;
  final Color leadingIconColor;
  final Color leadingBgColor;
  final IconData titleIcon;
  final Color titleIconColor;
  final String title;
  final String desc;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.leadingIcon,
    required this.leadingIconColor,
    required this.leadingBgColor,
    required this.titleIcon,
    required this.titleIconColor,
    required this.title,
    required this.desc,
    this.onTap,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E40AF).withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.leadingBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.leadingIcon, color: widget.leadingIconColor, size: 18),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(widget.titleIcon, color: widget.titleIconColor, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.desc,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.0,
                  color: Color(0xFF475569),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// INTERACTIVE SPEED TEST WIDGET
// ==========================================

class SpeedTestWidget extends StatefulWidget {
  const SpeedTestWidget({super.key});

  @override
  State<SpeedTestWidget> createState() => _SpeedTestWidgetState();
}

class _SpeedTestWidgetState extends State<SpeedTestWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _speedAnimation;
  bool _isRunning = false;
  double _currentSpeed = 0.0;
  int _ping = 0;
  double _upload = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _speedAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    )..addListener(() {
        setState(() {
          _currentSpeed = _speedAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _runSpeedTest() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _ping = 0;
      _upload = 0.0;
    });

    final targetDownload = 15.0 + math.Random().nextDouble() * 45.0; // Random speed between 15 and 60
    final targetUpload = 10.0 + math.Random().nextDouble() * 25.0;
    final randomPing = 4 + math.Random().nextInt(12);

    _animController.duration = const Duration(seconds: 3);
    _speedAnimation = Tween<double>(begin: 0.0, end: targetDownload).animate(
      CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn),
    );

    _animController.forward(from: 0.0).then((_) {
      // Finished download, animate upload
      setState(() {
        _ping = randomPing;
        _upload = targetUpload;
        _isRunning = false;
      });
      _animController.duration = const Duration(seconds: 2);
      _speedAnimation = Tween<double>(begin: targetDownload, end: 0.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut),
      );
      _animController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('PING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF94A3B8))),
                  Text(_ping == 0 ? '--' : '$_ping ms', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                ],
              ),
              Column(
                children: [
                  const Text('DOWNLOAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF94A3B8))),
                  Text(
                    _isRunning ? '${_currentSpeed.toStringAsFixed(1)} Mbps' : (_ping == 0 ? '--' : '${_currentSpeed.toStringAsFixed(1)} Mbps'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E40AF)),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('UPLOAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF94A3B8))),
                  Text(_upload == 0.0 ? '--' : '${_upload.toStringAsFixed(1)} Mbps', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF10B981))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            width: 200,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: SpeedometerPainter(value: _currentSpeed, maxValue: 60.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '${_currentSpeed.toStringAsFixed(1)}\nMbps',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, height: 1.1, color: Color(0xFF0F172A)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isRunning ? null : _runSpeedTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              elevation: 0,
            ),
            child: Text(
              _isRunning ? 'TESTING...' : 'RUN SPEED TEST',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double value;
  final double maxValue;

  SpeedometerPainter({required this.value, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 7),
      math.pi,
      math.pi,
      false,
      basePaint,
    );

    // Draw progress arc
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 7),
      math.pi,
      math.pi * percentage,
      false,
      progressPaint,
    );

    // Draw dial ticks
    final tickPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2;

    for (int i = 0; i <= 6; i++) {
      final angle = math.pi + (math.pi * (i / 6));
      final inner = Offset(
        center.dx + (radius - 22) * math.cos(angle),
        center.dy + (radius - 22) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + (radius - 14) * math.cos(angle),
        center.dy + (radius - 14) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Draw needle
    final needlePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final needleAngle = math.pi + (math.pi * percentage);
    final needleEnd = Offset(
      center.dx + (radius - 30) * math.cos(needleAngle),
      center.dy + (radius - 30) * math.sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFF0F172A));
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

// ==========================================
// PLANS TAB (ISP CATEGORY CLASSIFICATIONS)
// ==========================================

class PlansTab extends StatefulWidget {
  final List<PackagePlan> packages;
  final String popularTag;
  final int vatPercentage;
  final Function(PackagePlan) onSelectPlan;
  final bool showSyncOverlay;

  const PlansTab({
    super.key,
    required this.packages,
    required this.popularTag,
    required this.vatPercentage,
    required this.onSelectPlan,
    this.showSyncOverlay = false,
  });

  @override
  State<PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends State<PlansTab> {
  String _activeCategory = 'ALL'; // 'ALL', 'POPULAR', 'SPEED'

  List<PackagePlan> _getFilteredPackages() {
    if (_activeCategory == 'POPULAR') {
      return widget.packages.where((p) => p.isPopular).toList();
    } else if (_activeCategory == 'SPEED') {
      // Return plans with >= 40 Mbps
      return widget.packages.where((p) {
        final speedVal = int.tryParse(p.speed.replaceAll(RegExp(r'\D'), '')) ?? 0;
        return speedVal >= 40;
      }).toList();
    }
    return widget.packages;
  }

  Color _parseHexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF1E40AF);
    }
  }

  IconData _getPlanIcon(String faName) {
    switch (faName) {
      case 'fa-dove':
        return Icons.flutter_dash_rounded;
      case 'fa-bolt-lightning':
      case 'fa-bolt':
        return Icons.bolt_rounded;
      case 'fa-fire-flame-curved':
        return Icons.whatshot_rounded;
      case 'fa-droplet':
        return Icons.water_drop_rounded;
      case 'fa-crown':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.speed_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredPackages();

    return Column(
      children: [
        // Tab Filters Bar
        Container(
          height: 60,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCategoryBtn('ALL', 'All Plans'),
              _buildCategoryBtn('POPULAR', 'Popular'),
              _buildCategoryBtn('SPEED', 'High Speed'),
            ],
          ),
        ),

        // Plans List View (with local overlay)
        Expanded(
          child: Stack(
            children: [
              filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No plans found under this filter.',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                    )
                  : ListView.builder(
                      physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.all(24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final plan = filtered[index];
                        final cardColor = _parseHexColor(plan.color);
                        final btnColor = _parseHexColor(plan.btnColor);
                        final planIcon = _getPlanIcon(plan.icon);
                        final vatValue = plan.total - plan.price;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: plan.isPopular
                                ? Border.all(color: const Color(0xFF1E40AF), width: 2.5)
                                : Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: plan.isPopular
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF1E40AF).withValues(alpha: 0.08),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    )
                                  ]
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                      decoration: BoxDecoration(
                                        color: cardColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(planIcon, color: cardColor, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                              color: Color(0xFF1E40AF),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          Text(
                                            plan.tag,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Color(0xFFF1F5F9), height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan.speed,
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: Color(0xFF0F172A)),
                                        ),
                                        Text(
                                          '+${widget.vatPercentage}% VAT ⇒ ৳$vatValue',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Color(0xFF94A3B8)),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              '${plan.total}',
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF0F172A)),
                                            ),
                                            const SizedBox(width: 2),
                                            const Text(
                                              'TK',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Base ⇒ ৳${plan.price}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Color(0xFF94A3B8)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // ISP Features Bullets
                                const Column(
                                  children: [
                                    ISPBullet(text: 'Unlimited High-Speed Fiber Data'),
                                    ISPBullet(text: 'Low Latency Direct Routing (Gaming Support)'),
                                    ISPBullet(text: 'Real IP / Optical Router Options Available'),
                                    ISPBullet(text: '24/7 Priority Support Dispatch'),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                ElevatedButton(
                                  onPressed: () => widget.onSelectPlan(plan),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: btnColor,
                                    foregroundColor: Colors.white,
                                    elevation: plan.isGlowing ? 6 : 0,
                                    shadowColor: plan.isGlowing ? btnColor.withValues(alpha: 0.5) : null,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: const Text(
                                    'Select & Continue ⇒',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (plan.isPopular)
                            Positioned(
                              top: 0,
                              right: 24,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E40AF),
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                                ),
                                child: Text(
                                  widget.popularTag.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              if (widget.showSyncOverlay)
                Positioned.fill(
                  child: FullPageSyncOverlay(
                    isVisible: widget.showSyncOverlay,
                    type: SyncOverlayType.plans,
                    padding: const EdgeInsets.all(24),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBtn(String category, String label) {
    final active = _activeCategory == category;
    return InkWell(
      onTap: () {
        setState(() {
          _activeCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xFF1E40AF) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.w900 : FontWeight.bold,
            fontSize: 12,
            color: active ? const Color(0xFF1E40AF) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

class ISPBullet extends StatelessWidget {
  final String text;

  const ISPBullet({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// COVERAGE TAB (SEARCHABLE GRID)
// ==========================================

class CoverageTab extends StatefulWidget {
  final bool showSyncOverlay;
  const CoverageTab({super.key, this.showSyncOverlay = false});

  @override
  State<CoverageTab> createState() => _CoverageTabState();
}

class _CoverageTabState extends State<CoverageTab> {
  final List<String> _districts = const [
    "Bagerhat", "Bandarban", "Barguna", "Barishal", "Bhola", "Bogura", "Brahmanbaria", "Chandpur",
    "Chattogram", "Chuadanga", "Cox's Bazar", "Cumilla", "Dhaka", "Dinajpur", "Faridpur", "Feni",
    "Gaibandha", "Gazipur", "Gopalganj", "Habiganj", "Jamalpur", "Jashore", "Jhalokati", "Jhenaidah",
    "Joypurhat", "Khagrachhari", "Khulna", "Kishoreganj", "Kurigram", "Kushtia", "Lalmonirhat", "Laxmipur",
    "Madaripur", "Magura", "Manikganj", "Meherpur", "Moulvibazar", "Munshiganj", "Mymensingh", "Naogaon",
    "Narail", "Narayanganj", "Narsingdi", "Natore", "Chapainawabganj", "Netrokona", "Nilphamari", "Noakhali",
    "Pabna", "Panchagarh", "Patuakhali", "Pirojpur", "Rajbari", "Rajshahi", "Rangamati", "Rangpur",
    "Satkhira", "Shariatpur", "Sherpur", "Sirajganj", "Sunamganj", "Sylhet", "Tangail", "Thakurgaon"
  ];

  List<String> _filteredDistricts = [];

  @override
  void initState() {
    super.initState();
    _filteredDistricts = _districts;
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDistricts = _districts;
      } else {
        _filteredDistricts =
            _districts.where((d) => d.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // District Search Bar
          TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search District Coverage...',
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Dynamic Grid with local overlay
          Expanded(
            child: Stack(
              children: [
                _filteredDistricts.isEmpty
                    ? const Center(
                        child: Text(
                          'No districts found in coverage index.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                      )
                    : GridView.builder(
                        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredDistricts.length,
                        itemBuilder: (context, index) {
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Text(
                              _filteredDistricts[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          );
                        },
                      ),
                if (widget.showSyncOverlay)
                  Positioned.fill(
                    child: FullPageSyncOverlay(
                      isVisible: widget.showSyncOverlay,
                      type: SyncOverlayType.coverage,
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// DISTRICT SELECTION BOTTOM SHEET
// ==========================================

class DistrictSelectorSheet extends StatefulWidget {
  final Function(String) onSelected;

  const DistrictSelectorSheet({super.key, required this.onSelected});

  @override
  State<DistrictSelectorSheet> createState() => _DistrictSelectorSheetState();
}

class _DistrictSelectorSheetState extends State<DistrictSelectorSheet> {
  final List<String> _districts = const [
    "Bagerhat", "Bandarban", "Barguna", "Barishal", "Bhola", "Bogura", "Brahmanbaria", "Chandpur",
    "Chattogram", "Chuadanga", "Cox's Bazar", "Cumilla", "Dhaka", "Dinajpur", "Faridpur", "Feni",
    "Gaibandha", "Gazipur", "Gopalganj", "Habiganj", "Jamalpur", "Jashore", "Jhalokati", "Jhenaidah",
    "Joypurhat", "Khagrachhari", "Khulna", "Kishoreganj", "Kurigram", "Kushtia", "Lalmonirhat", "Laxmipur",
    "Madaripur", "Magura", "Manikganj", "Meherpur", "Moulvibazar", "Munshiganj", "Mymensingh", "Naogaon",
    "Narail", "Narayanganj", "Narsingdi", "Natore", "Chapainawabganj", "Netrokona", "Nilphamari", "Noakhali",
    "Pabna", "Panchagarh", "Patuakhali", "Pirojpur", "Rajbari", "Rajshahi", "Rangamati", "Rangpur",
    "Satkhira", "Shariatpur", "Sherpur", "Sirajganj", "Sunamganj", "Sylhet", "Tangail", "Thakurgaon"
  ];

  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _districts;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select District',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'BANGLADESH FIBER NETWORK',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (q) {
              setState(() {
                _filtered = _districts.where((d) => d.toLowerCase().contains(q.toLowerCase())).toList();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search for district...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final d = _filtered[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_rounded, color: Color(0xFF1E40AF)),
                  title: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  onTap: () {
                    widget.onSelected(d);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SUPPORT TAB (DIAGNOSTIC UTILITIES)
// ==========================================

class SupportTab extends StatefulWidget {
  final String whatsappNum;
  final String helplineNum;
  final String supportTemplate;
  final bool showSyncOverlay;

  const SupportTab({
    super.key,
    required this.whatsappNum,
    required this.helplineNum,
    required this.supportTemplate,
    this.showSyncOverlay = false,
  });

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _selectedDistrict;


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _openDistrictPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DistrictSelectorSheet(
          onSelected: (d) {
            setState(() {
              _selectedDistrict = d;
            });
          },
        );
      },
    );
  }

  Future<void> _callHelpline() async {
    final cleanNum = widget.helplineNum.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanNum');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot launch system dialer.')),
      );
    }
  }


  Future<void> _submitSupport() async {
    if (!_formKey.currentState!.validate() || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all support forms.')),
      );
      return;
    }

    final message = widget.supportTemplate
        .replaceAll('{name}', _nameController.text.trim())
        .replaceAll('{phone}', _phoneController.text.trim())
        .replaceAll('{district}', _selectedDistrict!)
        .replaceAll('{address}', _addressController.text.trim())
        .replaceAll('{details}', _detailsController.text.trim());

    final cleanWhatsApp = widget.whatsappNum.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappUri = Uri.parse(
      'https://wa.me/$cleanWhatsApp?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot launch WhatsApp client.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Persistent branding header
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Text(
                'Support Hub',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: Color(0xFF0F172A), letterSpacing: -1),
              ),
              Text(
                'TECHNICAL RESOLUTIONS & HELPLINE SUPPORT',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8), letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Scrollable form body with local overlay
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dynamic Card Form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Submit Troubleshooting Ticket',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter full name' : null,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter mobile number' : null,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _openDistrictPicker,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDistrict ?? 'Select ⇒ District',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: _selectedDistrict == null ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: Color(0xFF1E40AF)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter detailed address' : null,
                              decoration: InputDecoration(
                                labelText: 'Detailed Address',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _detailsController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Issue Details',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _submitSupport,
                              icon: const Icon(Icons.chat_rounded),
                              label: const Text('SUBMIT SUPPORT TICKET', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E40AF),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _callHelpline,
                      icon: const Icon(Icons.phone_rounded),
                      label: Text('CALL DIRECT HELPLINE: ${widget.helplineNum}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E40AF),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (widget.showSyncOverlay)
                Positioned.fill(
                  child: FullPageSyncOverlay(
                    isVisible: widget.showSyncOverlay,
                    type: SyncOverlayType.support,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

}

// ==========================================
// GET CONNECTED / ORDER TAB
// ==========================================

class OrderTab extends StatefulWidget {
  final String whatsappNum;
  final String orderTemplate;
  final PackagePlan? selectedPlan;
  final bool showSyncOverlay;

  const OrderTab({
    super.key,
    required this.whatsappNum,
    required this.orderTemplate,
    this.selectedPlan,
    this.showSyncOverlay = false,
  });

  @override
  State<OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends State<OrderTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedDistrict;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _openDistrictPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DistrictSelectorSheet(
          onSelected: (d) {
            setState(() {
              _selectedDistrict = d;
            });
          },
        );
      },
    );
  }

  Future<void> _submitOrder() async {
    if (widget.selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an internet plan first.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate() || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all onboarding details.')),
      );
      return;
    }

    final pName = "${widget.selectedPlan!.name} (${widget.selectedPlan!.speed})";
    final message = widget.orderTemplate
        .replaceAll('{name}', _nameController.text.trim())
        .replaceAll('{phone}', _phoneController.text.trim())
        .replaceAll('{district}', _selectedDistrict!)
        .replaceAll('{address}', _addressController.text.trim())
        .replaceAll('{package}', pName);

    final cleanWhatsApp = widget.whatsappNum.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappUri = Uri.parse(
      'https://wa.me/$cleanWhatsApp?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot launch WhatsApp client.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPlan = widget.selectedPlan != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Persistent branding header
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Text(
                'Order Connection',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF0F172A), letterSpacing: -1),
              ),
              Text(
                'ONBOARDING CUSTOMER PROFILING',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF94A3B8), letterSpacing: 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Scrollable form body with local overlay
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Order Form Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter full name' : null,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter mobile number' : null,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            InkWell(
                              onTap: _openDistrictPicker,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDistrict ?? 'Select ⇒ District',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: _selectedDistrict == null ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, color: Color(0xFF1E40AF)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Boarding Ticket Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFF59E0B)),
                              ),
                              child: hasPlan
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              widget.selectedPlan!.name,
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E40AF)),
                                            ),
                                            const Icon(Icons.receipt_long_rounded, color: Color(0xFF1E40AF), size: 20),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${widget.selectedPlan!.speed} Speed Plan',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E40AF)),
                                        ),
                                        const Divider(color: Color(0xFFF59E0B), height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Monthly Cost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF90CAF9))),
                                            Text('৳${widget.selectedPlan!.price} TK', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1E40AF))),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('VAT (${widget.selectedPlan!.vat}%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF90CAF9))),
                                            Text('৳${widget.selectedPlan!.total - widget.selectedPlan!.price} TK', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1E40AF))),
                                          ],
                                        ),
                                        const Divider(color: Color(0xFFF59E0B), height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Grand Total Cost', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                                            Text('৳${widget.selectedPlan!.total} TK', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E40AF))),
                                          ],
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Please select an internet plan from Plans Tab to complete connection ordering.',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E40AF)),
                                    ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _addressController,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter detailed address' : null,
                              decoration: InputDecoration(
                                labelText: 'Detailed Address',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _submitOrder,
                              icon: const Icon(Icons.chat_rounded),
                              label: const Text('SUBMIT ORDER PORTAL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E40AF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (widget.showSyncOverlay)
                Positioned.fill(
                  child: FullPageSyncOverlay(
                    isVisible: widget.showSyncOverlay,
                    type: SyncOverlayType.order,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// FULL SCREEN SYNC OVERLAY
// ==========================================

enum SyncOverlayType { home, plans, coverage, support, order }

class FullPageSyncOverlay extends StatefulWidget {
  final bool isVisible;
  final SyncOverlayType type;
  final EdgeInsets padding;

  const FullPageSyncOverlay({
    super.key,
    required this.isVisible,
    this.type = SyncOverlayType.home,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  State<FullPageSyncOverlay> createState() => _FullPageSyncOverlayState();
}

class _FullPageSyncOverlayState extends State<FullPageSyncOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _colorAnimation = Tween<double>(begin: 0.1, end: 0.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHomeSkeleton(Color skeletonColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Brand Promo Hero Card skeleton
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: 24),

        // Quick Action Tiles Row skeleton
        Row(
          children: [
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Features List Header skeleton
        Center(
          child: Container(
            width: 160,
            height: 36,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 6 features in a 2-column layout skeleton
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCardSkeleton(Color skeletonColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: skeletonColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 140, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 80, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 32, width: 100, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(8))),
              Container(height: 48, width: 120, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(24))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSkeleton(Color skeletonColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPlanCardSkeleton(skeletonColor),
        _buildPlanCardSkeleton(skeletonColor),
      ],
    );
  }

  Widget _buildCoverageSkeleton(Color skeletonColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  Widget _buildFormSkeleton(Color skeletonColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 20, width: 150, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 24),
          Container(height: 56, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          Container(height: 56, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          Container(height: 56, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          Container(height: 56, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 24),
          Container(height: 56, decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(24))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          final shimmerVal = _colorAnimation.value;
          final skeletonColor = Color.lerp(
            const Color(0xFFF1F5F9), // light white-ish gray
            const Color(0xFFCBD5E1), // slightly darker gray (light-black)
            shimmerVal,
          )!;

          Widget body;
          switch (widget.type) {
            case SyncOverlayType.home:
              body = _buildHomeSkeleton(skeletonColor);
              break;
            case SyncOverlayType.plans:
              body = _buildPlansSkeleton(skeletonColor);
              break;
            case SyncOverlayType.coverage:
              body = _buildCoverageSkeleton(skeletonColor);
              break;
            case SyncOverlayType.support:
            case SyncOverlayType.order:
              body = _buildFormSkeleton(skeletonColor);
              break;
          }

          return Material(
            color: Colors.transparent,
            child: Container(
              color: const Color(0xFFF8FAFC), // match page background
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: widget.padding,
                child: body,
              ),
            ),
          );
        },
      ),
    );
  }
}
