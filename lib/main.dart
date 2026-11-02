import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const SmartStockApp());
}

// ───────────────────────── Colours ─────────────────────────
class C {
  // Page
  static const bg = Color(0xFFF4F7FC);
  static const panel = Colors.white;
  static const panelAlt = Color(0xFFF1F5FB);
  static const border = Color(0xFFE2E8F2);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);

  // Menu (navy sidebar)
  static const navy = Color(0xFF0B2A5B);
  static const navyDark = Color(0xFF081F44);
  static const accent = Color(0xFF1D5FE0);

  // Status colours
  static const blue = Color(0xFF2563EB);
  static const green = Color(0xFF10B981);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const purple = Color(0xFFA855F7);
  static const grey = Color(0xFF64748B);
}

class SmartStockApp extends StatelessWidget {
  const SmartStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartStock',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: C.accent,
        scaffoldBackgroundColor: C.bg,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

// ───────────────────────── Notifications model ─────────────────────────
class AppNotification {
  final String title, body, time;
  final IconData icon;
  final Color color;
  final int page; // page to open when tapped
  bool read;

  AppNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    required this.page,
    this.read = false,
  });
}

// ───────────────────────── Main screen ─────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  bool collapsed = false;

  final List<String> pages = [
    'Dashboard',
    'Products',
    'Categories',
    'Suppliers',
    'Purchases',
    'Sales',
    'Stock Movements',
    'Stock Alerts',
    'Reports',
    'Settings',
  ];

  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.inventory_2_rounded,
    Icons.category_rounded,
    Icons.local_shipping_rounded,
    Icons.shopping_bag_rounded,
    Icons.point_of_sale_rounded,
    Icons.swap_horiz_rounded,
    Icons.notifications_active_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_rounded,
  ];

  // Starter notifications. Later, add new ones from real events
  // (low stock, new sale, purchase received...).
  final List<AppNotification> notifications = [
    AppNotification(
      title: 'Welcome to SmartStock',
      body: 'Your shop system is ready to use.',
      time: 'Just now',
      icon: Icons.waving_hand_rounded,
      color: C.blue,
      page: 0,
    ),
    AppNotification(
      title: 'Add your first products',
      body: 'Go to Products to start building your stock list.',
      time: 'Today',
      icon: Icons.inventory_2_rounded,
      color: C.green,
      page: 1,
    ),
    AppNotification(
      title: 'Set up your shop details',
      body: 'Add shop name, address and phone in Settings.',
      time: 'Today',
      icon: Icons.settings_rounded,
      color: C.orange,
      page: 9,
    ),
  ];

  int get unread => notifications.where((n) => !n.read).length;

  // ───────────── App data (kept in memory for now) ─────────────
  final List<Product> products = [];
  final List<Activity> activities = [];
  final List<String> categories = [
    'Drinks',
    'Food',
    'Household',
    'Bakery',
    'Other',
  ];

  void logActivity(String text, IconData icon, Color color) {
    setState(() => activities.insert(0, Activity(text, icon, color)));
  }

  void notifyLowStock(Product p) {
    final out = p.isOut;
    setState(() {
      notifications.removeWhere((n) => n.title.endsWith(': ${p.name}'));
      notifications.insert(
        0,
        AppNotification(
          title: '${out ? 'Out of stock' : 'Low stock'}: ${p.name}',
          body: out
              ? 'No items left. Please restock.'
              : 'Only ${p.quantity} left (alert level ${p.lowLevel}).',
          time: 'Just now',
          icon: out ? Icons.error_rounded : Icons.warning_amber_rounded,
          color: out ? C.red : C.orange,
          page: 7,
        ),
      );
    });
  }

  Widget buildPage() {
    switch (selectedIndex) {
      case 0:
        return DashboardPage(
          products: products,
          activities: activities,
          onOpen: goTo,
        );
      case 1:
        return ProductsPage(
          products: products,
          categories: categories,
          onChanged: () => setState(() {}),
          onLowStock: notifyLowStock,
          onActivity: logActivity,
        );
      default:
        return buildOtherPage();
    }
  }

  void goTo(int index, {bool closeDrawer = false}) {
    setState(() => selectedIndex = index);
    if (closeDrawer) Navigator.pop(context);
  }

  // ───────────── Sidebar ─────────────
  Widget buildSidebar({bool inDrawer = false}) {
    final compact = collapsed && !inDrawer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: compact ? 82 : 252,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.navy, C.navyDark],
        ),
      ),
      child: ClipRect(
        child: Column(
          children: [
            const SizedBox(height: 22),
            // Logo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 20),
              child: Row(
                mainAxisAlignment:
                    compact ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_rounded,
                        color: C.accent, size: 24),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    const Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SmartStock',
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('Shop Management',
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 26),
            // Menu items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: pages.length,
                itemBuilder: (context, i) => _navItem(i, compact, inDrawer),
              ),
            ),
            // User card
            _userCard(compact),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int i, bool compact, bool inDrawer) {
    final selected = selectedIndex == i;
    final badge = (i == 7 && unread > 0);

    final tile = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.white.withValues(alpha: 0.07),
        onTap: () => goTo(i, closeDrawer: inDrawer),
        child: Container(
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 14),
          decoration: BoxDecoration(
            color: selected ? C.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: C.accent.withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment:
                compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icons[i],
                  size: 21, color: selected ? Colors.white : Colors.white70),
              if (!compact) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    pages[i],
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 14,
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (badge)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: C.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$unread',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: compact ? Tooltip(message: pages[i], child: tile) : tile,
    );
  }

  Widget _userCard(bool compact) {
    final avatar = Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF60A5FA), C.accent]),
      ),
      child: const Text('A',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: compact
          ? Center(child: avatar)
          : Row(
              children: [
                avatar,
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600)),
                      Text('Shop owner',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style:
                              TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Logout',
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.white70, size: 19),
                ),
              ],
            ),
    );
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login system will be added in a later step.')),
    );
  }

  // ───────────── Top bar ─────────────
  Widget buildTopBar(bool isDesktop) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: C.border)),
      ),
      child: Row(
        children: [
          if (isDesktop)
            IconButton(
              tooltip: collapsed ? 'Expand menu' : 'Collapse menu',
              onPressed: () => setState(() => collapsed = !collapsed),
              icon: Icon(
                  collapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
                  color: C.text),
            )
          else
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded, color: C.text),
              ),
            ),
          const SizedBox(width: 6),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    style: const TextStyle(fontSize: 13.5, color: C.text),
                    decoration: InputDecoration(
                      hintText: 'Search products, sales, suppliers...',
                      hintStyle:
                          const TextStyle(color: C.muted, fontSize: 13.5),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 20, color: C.muted),
                      filled: true,
                      fillColor: C.panelAlt,
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: C.accent),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _notificationButton(),
          const SizedBox(width: 6),
          _profileButton(isDesktop),
        ],
      ),
    );
  }

  // ───────────── Notifications popup ─────────────
  Widget _notificationButton() {
    return PopupMenuButton<void>(
      tooltip: 'Notifications',
      offset: const Offset(0, 52),
      color: Colors.white,
      elevation: 12,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: C.border),
      ),
      padding: EdgeInsets.zero,
      itemBuilder: (popupContext) => [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: StatefulBuilder(
            builder: (ctx, setInner) {
              final w = math.min(380.0, MediaQuery.of(ctx).size.width - 32);
              return SizedBox(
                width: w,
                child: _notificationPanel(popupContext, setInner),
              );
            },
          ),
        ),
      ],
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: C.panelAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none_rounded,
                color: C.text, size: 23),
            if (unread > 0)
              Positioned(
                top: 5,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: C.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text('$unread',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _notificationPanel(BuildContext popupContext, StateSetter setInner) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
          child: Row(
            children: [
              const Text('Notifications',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: C.text)),
              const SizedBox(width: 8),
              if (unread > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: C.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$unread new',
                      style: const TextStyle(
                          color: C.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              const Spacer(),
              TextButton(
                onPressed: unread == 0
                    ? null
                    : () {
                        setState(() {
                          for (final n in notifications) {
                            n.read = true;
                          }
                        });
                        setInner(() {});
                      },
                child: const Text('Mark all read',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: C.border),
        if (notifications.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 38, color: C.muted),
                  SizedBox(height: 8),
                  Text('You are all caught up.',
                      style: TextStyle(color: C.muted)),
                ],
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: C.border),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return InkWell(
                  onTap: () {
                    setState(() => n.read = true);
                    Navigator.pop(popupContext);
                    goTo(n.page);
                  },
                  child: Container(
                    color: n.read
                        ? Colors.transparent
                        : C.accent.withValues(alpha: 0.05),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: n.color.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(n.icon, color: n.color, size: 19),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title,
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      color: C.text,
                                      fontWeight: n.read
                                          ? FontWeight.w500
                                          : FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(n.body,
                                  style: const TextStyle(
                                      fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(n.time,
                                  style: const TextStyle(
                                      fontSize: 11, color: C.muted)),
                            ],
                          ),
                        ),
                        if (!n.read)
                          Container(
                            margin: const EdgeInsets.only(top: 6, left: 6),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: C.accent, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const Divider(height: 1, color: C.border),
        InkWell(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          onTap: () {
            Navigator.pop(popupContext);
            goTo(7);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Center(
              child: Text('View all stock alerts →',
                  style: TextStyle(
                      color: C.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────── Profile popup ─────────────
  Widget _profileButton(bool isDesktop) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 52),
      color: Colors.white,
      elevation: 12,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: C.border),
      ),
      onSelected: (v) {
        if (v == 'settings') goTo(9);
        if (v == 'logout') _logout();
        if (v == 'profile') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile page will be added later.')),
          );
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin',
                  style: TextStyle(
                      color: C.text, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Shop owner',
                  style: TextStyle(color: C.muted, fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(children: [
            Icon(Icons.person_outline_rounded, size: 19, color: C.muted),
            SizedBox(width: 12),
            Text('My Profile'),
          ]),
        ),
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(children: [
            Icon(Icons.settings_outlined, size: 19, color: C.muted),
            SizedBox(width: 12),
            Text('Settings'),
          ]),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 19, color: C.red),
            SizedBox(width: 12),
            Text('Logout', style: TextStyle(color: C.red)),
          ]),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    LinearGradient(colors: [Color(0xFF60A5FA), C.accent]),
              ),
              child: const Text('A',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 10),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: C.text)),
                  Text('Shop owner',
                      style: TextStyle(fontSize: 11, color: C.muted)),
                ],
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: C.muted),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildOtherPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[selectedIndex], size: 60, color: C.muted),
          const SizedBox(height: 16),
          Text(
            pages[selectedIndex],
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: C.text),
          ),
          const SizedBox(height: 8),
          const Text(
            'This page will be developed in the next steps.',
            style: TextStyle(color: C.muted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        return Scaffold(
          drawer: isDesktop
              ? null
              : Drawer(
                  width: 252,
                  shape: const RoundedRectangleBorder(),
                  child: buildSidebar(inDrawer: true),
                ),
          body: Row(
            children: [
              if (isDesktop) buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    buildTopBar(isDesktop),
                    Expanded(child: buildPage()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ───────────────────────── Models & helpers ─────────────────────────
class CatStyle {
  final IconData icon;
  final Color color;
  const CatStyle(this.icon, this.color);
}

CatStyle catStyle(String category) {
  switch (category) {
    case 'Drinks':
      return const CatStyle(Icons.local_drink_rounded, Color(0xFF2563EB));
    case 'Food':
      return const CatStyle(Icons.rice_bowl_rounded, Color(0xFFF59E0B));
    case 'Household':
      return const CatStyle(
          Icons.cleaning_services_rounded, Color(0xFF8B5CF6));
    case 'Bakery':
      return const CatStyle(Icons.bakery_dining_rounded, Color(0xFFEC4899));
    default:
      return const CatStyle(Icons.inventory_2_rounded, Color(0xFF14B8A6));
  }
}

class Product {
  String name, category, supplier, sku;
  int costPrice, price, quantity, lowLevel;

  Product({
    required this.name,
    required this.category,
    this.supplier = '',
    this.sku = '',
    this.costPrice = 0,
    required this.price,
    required this.quantity,
    this.lowLevel = 5,
  });

  bool get isOut => quantity <= 0;
  bool get isLow => quantity > 0 && quantity <= lowLevel;
  bool get isIn => quantity > lowLevel;

  String get statusLabel => isOut
      ? 'Out of Stock'
      : isLow
          ? 'Low Stock'
          : 'In Stock';

  Color get statusColor => isOut
      ? C.red
      : isLow
          ? C.orange
          : C.green;
}

class Activity {
  final String text;
  final IconData icon;
  final Color color;
  final DateTime time;
  Activity(this.text, this.icon, this.color) : time = DateTime.now();
}

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 60) return 'Just now';
  if (d.inMinutes < 60) return '${d.inMinutes} mins ago';
  if (d.inHours < 24) return '${d.inHours} hours ago';
  return '${d.inDays} days ago';
}

String rwf(num n) {
  final s = n.round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return 'RWF $b';
}

Widget gridWrap(double maxW, List<Widget> children, int maxCols, double minW,
    {double gap = 14}) {
  final cols = (maxW / minW).floor().clamp(1, maxCols).toInt();
  final w = (maxW - gap * (cols - 1)) / cols;
  return Wrap(
    spacing: gap,
    runSpacing: gap,
    children: [for (final c in children) SizedBox(width: w, child: c)],
  );
}

// ───────────────────────── Dashboard ─────────────────────────
class DashboardPage extends StatelessWidget {
  final List<Product> products;
  final List<Activity> activities;
  final void Function(int) onOpen;

  const DashboardPage({
    super.key,
    required this.products,
    required this.activities,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final total = products.length;
    final units = products.fold<int>(0, (a, p) => a + p.quantity);
    final inStock = products.where((p) => p.isIn).length;
    final low = products.where((p) => p.isLow).length;
    final out = products.where((p) => p.isOut).length;
    final cost = products.fold<int>(0, (a, p) => a + p.costPrice * p.quantity);
    final retail = products.fold<int>(0, (a, p) => a + p.price * p.quantity);
    final costSum = products.fold<int>(0, (a, p) => a + p.costPrice);
    final avgCost = total == 0 ? 0 : (costSum / total).round();
    final avgUnits = total == 0 ? 0 : (units / total).round();

    final byCat = <String, int>{};
    for (final p in products) {
      byCat[p.category] = (byCat[p.category] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth > 900;

              final summary = Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PanelTitle(
                        icon: Icons.bar_chart_rounded,
                        title: 'Inventory Summary'),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                          child: StatTile('TOTAL UNITS', '$units', C.blue)),
                      const SizedBox(width: 10),
                      Expanded(
                          child:
                              StatTile('PRODUCTS', '$total', C.purple)),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: StatTile('COST VALUE', rwf(cost), C.green)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: StatTile(
                              'RETAIL VALUE', rwf(retail), C.orange)),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: StatTile(
                              'AVG COST / PRODUCT', rwf(avgCost), C.blue)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: StatTile('AVG UNITS / PRODUCT',
                              '$avgUnits', Colors.pinkAccent)),
                    ]),
                  ],
                ),
              );

              final activity = Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PanelTitle(
                        icon: Icons.history_rounded,
                        title: 'Recent Activities'),
                    const SizedBox(height: 14),
                    if (activities.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 34),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history_rounded,
                                  size: 40, color: C.muted),
                              SizedBox(height: 10),
                              Text('No activities yet.',
                                  style: TextStyle(color: C.muted)),
                            ],
                          ),
                        ),
                      )
                    else
                      for (final a in activities.take(6))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: a.color.withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(a.icon, color: a.color, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(a.text,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: C.text)),
                                    Text(timeAgo(a.time),
                                        style: const TextStyle(
                                            fontSize: 11.5, color: C.muted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              );

              final distribution = Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PanelTitle(
                        icon: Icons.pie_chart_outline_rounded,
                        title: 'Products by Category & Stock Health'),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('BY CATEGORY',
                                  style: TextStyle(
                                      color: C.muted,
                                      fontSize: 10,
                                      letterSpacing: 0.6)),
                              const SizedBox(height: 12),
                              Donut(
                                centerValue: '$total',
                                centerLabel: 'PRODUCTS',
                                segments: [
                                  for (final e in byCat.entries)
                                    Seg(e.value.toDouble(),
                                        catStyle(e.key).color),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (byCat.isEmpty)
                                const Text('No products yet',
                                    style: TextStyle(
                                        color: C.muted, fontSize: 12))
                              else
                                for (final e in byCat.entries)
                                  LegendRow(catStyle(e.key).color, e.key,
                                      '${e.value}'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('STOCK HEALTH',
                                  style: TextStyle(
                                      color: C.muted,
                                      fontSize: 10,
                                      letterSpacing: 0.6)),
                              const SizedBox(height: 12),
                              Donut(
                                centerValue: '$total',
                                centerLabel: 'PRODUCTS',
                                segments: [
                                  Seg(inStock.toDouble(), C.green),
                                  Seg(low.toDouble(), C.orange),
                                  Seg(out.toDouble(), C.red),
                                ],
                              ),
                              const SizedBox(height: 14),
                              LegendRow(C.green, 'In Stock', '$inStock'),
                              LegendRow(C.orange, 'Low Stock', '$low'),
                              LegendRow(C.red, 'Out of Stock', '$out'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 12,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dashboard',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: C.text)),
                          SizedBox(height: 4),
                          Text('Welcome back, Admin 👋',
                              style: TextStyle(color: C.muted, fontSize: 14)),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: () => onOpen(1),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Product'),
                        style: FilledButton.styleFrom(
                          backgroundColor: C.accent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  gridWrap(box.maxWidth, [
                    GradientStatCard(
                      title: 'Total Products',
                      value: '$total',
                      sub: '$units units in stock',
                      icon: Icons.inventory_2_rounded,
                      colors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    GradientStatCard(
                      title: 'Stock Value (retail)',
                      value: rwf(retail),
                      sub: 'Cost: ${rwf(cost)}',
                      icon: Icons.payments_rounded,
                      colors: const [Color(0xFF34D399), Color(0xFF059669)],
                    ),
                    GradientStatCard(
                      title: 'Low Stock',
                      value: '$low',
                      sub: 'Need restocking soon',
                      icon: Icons.trending_down_rounded,
                      colors: const [Color(0xFFFBBF24), Color(0xFFEA580C)],
                    ),
                    GradientStatCard(
                      title: 'Out of Stock',
                      value: '$out',
                      sub: 'Zero items on hand',
                      icon: Icons.error_outline_rounded,
                      colors: const [Color(0xFFF87171), Color(0xFFDC2626)],
                    ),
                  ], 4, 235),
                  const SizedBox(height: 14),
                  StockHealthBar(inStock: inStock, low: low, out: out),
                  const SizedBox(height: 14),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: summary),
                        const SizedBox(width: 14),
                        Expanded(flex: 2, child: activity),
                      ],
                    )
                  else ...[
                    summary,
                    const SizedBox(height: 14),
                    activity,
                  ],
                  const SizedBox(height: 14),
                  distribution,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class GradientStatCard extends StatelessWidget {
  final String title, value, sub;
  final IconData icon;
  final List<Color> colors;

  const GradientStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12.5)),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 11.5)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Products page ─────────────────────────
String genSku(Iterable<String> used) {
  final set = used.map((e) => e.toUpperCase()).toSet();
  int n = 1;
  while (set.contains('SKU-${n.toString().padLeft(4, '0')}')) {
    n++;
  }
  return 'SKU-${n.toString().padLeft(4, '0')}';
}

class StockAdjust {
  final Product product;
  final int delta;
  StockAdjust(this.product, this.delta);
}

class ProductsPage extends StatefulWidget {
  final List<Product> products;
  final List<String> categories;
  final VoidCallback onChanged;
  final void Function(Product) onLowStock;
  final void Function(String, IconData, Color) onActivity;

  const ProductsPage({
    super.key,
    required this.products,
    required this.categories,
    required this.onChanged,
    required this.onLowStock,
    required this.onActivity,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String query = '';
  String tab = 'All';
  Set<String> fStatus = {};
  Set<String> fCats = {};
  String sortKey = 'name';
  bool asc = true;
  int page = 0;
  int rows = 10;

  // ───── data ─────
  List<Product> get filtered {
    final q = query.toLowerCase();
    final list = widget.products.where((p) {
      if (q.isNotEmpty &&
          !(p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q) ||
              p.supplier.toLowerCase().contains(q))) {
        return false;
      }
      if (tab == 'In Stock' && !p.isIn) return false;
      if (tab == 'Low Stock' && !p.isLow) return false;
      if (tab == 'Out of Stock' && !p.isOut) return false;
      if (fStatus.isNotEmpty && !fStatus.contains(p.statusLabel)) return false;
      if (fCats.isNotEmpty && !fCats.contains(p.category)) return false;
      return true;
    }).toList();

    int cmp(Product a, Product b) {
      switch (sortKey) {
        case 'stock':
          return a.quantity.compareTo(b.quantity);
        case 'price':
          return a.price.compareTo(b.price);
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    }

    list.sort((a, b) => asc ? cmp(a, b) : cmp(b, a));
    return list;
  }

  void sortBy(String key) {
    setState(() {
      if (sortKey == key) {
        asc = !asc;
      } else {
        sortKey = key;
        asc = true;
      }
    });
  }

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  // ───── actions ─────
  Future<void> addProduct() async {
    final r = await showDialog<Product>(
      context: context,
      builder: (_) => ProductFormDialog(
        categories: widget.categories,
        usedSkus: widget.products.map((p) => p.sku).toList(),
      ),
    );
    if (r == null) return;
    if (r.sku.isEmpty) r.sku = genSku(widget.products.map((p) => p.sku));
    widget.products.insert(0, r);
    setState(() => page = 0);
    widget.onChanged();
    widget.onActivity(
        'Product added: ${r.name}', Icons.add_box_rounded, C.green);
    if (r.isLow || r.isOut) widget.onLowStock(r);
    toast('${r.name} added successfully');
  }

  Future<void> editProduct(Product p) async {
    final r = await showDialog<Product>(
      context: context,
      builder: (_) => ProductFormDialog(
        categories: widget.categories,
        product: p,
        usedSkus: widget.products
            .where((e) => e != p)
            .map((e) => e.sku)
            .toList(),
      ),
    );
    if (r == null) return;
    final newSku = r.sku.isNotEmpty
        ? r.sku
        : (p.sku.isNotEmpty
            ? p.sku
            : genSku(widget.products.map((e) => e.sku)));
    p
      ..name = r.name
      ..sku = newSku
      ..category = r.category
      ..supplier = r.supplier
      ..costPrice = r.costPrice
      ..price = r.price
      ..quantity = r.quantity
      ..lowLevel = r.lowLevel;
    widget.onChanged();
    widget.onActivity('Product updated: ${p.name}', Icons.edit_rounded, C.blue);
    if (p.isLow || p.isOut) widget.onLowStock(p);
    toast('${p.name} updated');
  }

  void cloneProduct(Product p) {
    final c = Product(
      name: '${p.name} (Copy)',
      sku: genSku(widget.products.map((e) => e.sku)),
      category: p.category,
      supplier: p.supplier,
      costPrice: p.costPrice,
      price: p.price,
      quantity: p.quantity,
      lowLevel: p.lowLevel,
    );
    widget.products.insert(0, c);
    widget.onChanged();
    widget.onActivity(
        'Product cloned: ${c.name}', Icons.copy_rounded, C.purple);
    toast('${c.name} created');
  }

  Future<void> deleteProduct(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete product?'),
        content: Text('"${p.name}" will be removed from your stock list.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: C.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    widget.products.remove(p);
    widget.onChanged();
    widget.onActivity(
        'Product deleted: ${p.name}', Icons.delete_rounded, C.red);
    toast('${p.name} deleted');
  }

  Future<void> adjustStock(String mode, {Product? preset}) async {
    if (widget.products.isEmpty) {
      toast('Add a product first.');
      return;
    }
    final r = await showDialog<StockAdjust>(
      context: context,
      builder: (_) => StockAdjustDialog(
        products: widget.products,
        mode: mode,
        initial: preset,
      ),
    );
    if (r == null) return;
    r.product.quantity = math.max(0, r.product.quantity + r.delta);
    widget.onChanged();
    final added = r.delta > 0;
    widget.onActivity(
      added
          ? 'Stock added: +${r.delta} ${r.product.name}'
          : 'Stock removed: ${r.delta} ${r.product.name}',
      added ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
      added ? C.green : C.orange,
    );
    if (!added && (r.product.isLow || r.product.isOut)) {
      widget.onLowStock(r.product);
    }
    toast('${r.product.name}: ${r.product.quantity} now in stock');
  }

  void viewProduct(Product p) {
    showDialog(
      context: context,
      builder: (_) => ProductDetailsDialog(
        product: p,
        onEdit: () => editProduct(p),
      ),
    );
  }

  // ───── UI pieces ─────
  ShapeBorder get _popupShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: C.border),
      );

  Widget _toolButton(IconData icon, String label, {Widget? trailing}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: C.text),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: C.text)),
          if (trailing != null) ...[const SizedBox(width: 6), trailing],
        ],
      ),
    );
  }

  Widget _manageStockButton() {
    return PopupMenuButton<String>(
      tooltip: 'Manage Stock',
      offset: const Offset(0, 48),
      color: Colors.white,
      elevation: 10,
      shape: _popupShape,
      onSelected: (v) => adjustStock(v),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'add',
          child: Row(children: [
            Icon(Icons.add_circle_outline_rounded, size: 19, color: C.green),
            SizedBox(width: 12),
            Text('Add stock'),
          ]),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(children: [
            Icon(Icons.remove_circle_outline_rounded,
                size: 19, color: C.orange),
            SizedBox(width: 12),
            Text('Remove items'),
          ]),
        ),
      ],
      child: _toolButton(Icons.inventory_rounded, 'Manage Stock',
          trailing: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: C.muted)),
    );
  }

  Widget _filtersButton() {
    final count = fStatus.length + fCats.length;
    return PopupMenuButton<void>(
      tooltip: 'Filters',
      offset: const Offset(0, 48),
      color: Colors.white,
      elevation: 12,
      shadowColor: Colors.black26,
      shape: _popupShape,
      padding: EdgeInsets.zero,
      itemBuilder: (popupCtx) {
        final tStatus = <String>{...fStatus};
        final tCats = <String>{...fCats};
        return [
          PopupMenuItem<void>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: StatefulBuilder(
              builder: (ctx, setInner) {
                Widget section(String title, List<String> items,
                    Set<String> selected) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: C.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: const BoxDecoration(
                            color: C.panelAlt,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(11)),
                          ),
                          child: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: C.text)),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 190),
                          child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: [
                              for (final s in items)
                                CheckboxListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  activeColor: C.accent,
                                  value: selected.contains(s),
                                  title: Text(s,
                                      style: const TextStyle(fontSize: 13)),
                                  onChanged: (v) => setInner(() {
                                    if (v == true) {
                                      selected.add(s);
                                    } else {
                                      selected.remove(s);
                                    }
                                  }),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final w = math.min(330.0, MediaQuery.of(ctx).size.width - 32);
                return SizedBox(
                  width: w,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Filters',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: C.text)),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => setInner(() {
                                tStatus.clear();
                                tCats.clear();
                              }),
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: const Text('Reset'),
                              style: TextButton.styleFrom(
                                  foregroundColor: C.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        section('Product Stock',
                            const ['In Stock', 'Low Stock', 'Out of Stock'],
                            tStatus),
                        section('Category', widget.categories, tCats),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(popupCtx),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: C.text,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              onPressed: () {
                                setState(() {
                                  fStatus = tStatus;
                                  fCats = tCats;
                                  page = 0;
                                });
                                Navigator.pop(popupCtx);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: C.accent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Apply Filter'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ];
      },
      child: _toolButton(
        Icons.tune_rounded,
        'Filters',
        trailing: count == 0
            ? null
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: C.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
      ),
    );
  }

  Widget _tabs(List<Product> all) {
    final items = <MapEntry<String, int>>[
      MapEntry('All', all.length),
      MapEntry('In Stock', all.where((p) => p.isIn).length),
      MapEntry('Low Stock', all.where((p) => p.isLow).length),
      MapEntry('Out of Stock', all.where((p) => p.isOut).length),
    ];
    final colors = {
      'All': C.accent,
      'In Stock': C.green,
      'Low Stock': C.orange,
      'Out of Stock': C.red,
    };
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in items)
            InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => setState(() {
                tab = e.key;
                page = 0;
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: tab == e.key
                      ? colors[e.key]!.withValues(alpha: 0.13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Text(e.key == 'All' ? 'All Stock' : e.key,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: tab == e.key
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: tab == e.key ? colors[e.key] : C.muted)),
                    const SizedBox(width: 7),
                    Text('${e.value}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: tab == e.key ? colors[e.key] : C.muted)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 44,
      child: TextField(
        onChanged: (v) => setState(() {
          query = v.trim();
          page = 0;
        }),
        style: const TextStyle(fontSize: 13.5, color: C.text),
        decoration: InputDecoration(
          hintText: 'Search name, category or SKU',
          hintStyle: const TextStyle(color: C.muted, fontSize: 13.5),
          prefixIcon:
              const Icon(Icons.search_rounded, size: 20, color: C.muted),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: C.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: C.accent),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: C.muted)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: C.text)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(String label, int flex, {String? sortKeyName}) {
    final active = sortKeyName != null && sortKey == sortKeyName;
    final text = Text(label,
        style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: active ? C.accent : C.muted));
    return Expanded(
      flex: flex,
      child: sortKeyName == null
          ? text
          : InkWell(
              onTap: () => sortBy(sortKeyName),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: text),
                  const SizedBox(width: 4),
                  Icon(
                    active
                        ? (asc
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded)
                        : Icons.unfold_more_rounded,
                    size: 15,
                    color: active ? C.accent : C.muted,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statusPill(Product p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: p.statusColor.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: p.statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(p.statusLabel,
              style: TextStyle(
                  color: p.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _row(Product p) {
    final st = catStyle(p.category);
    final sub = p.supplier.isEmpty ? p.category : p.supplier;
    final fill = (p.quantity / math.max(1, p.lowLevel * 3)).clamp(0.0, 1.0);

    return InkWell(
      onTap: () => viewProduct(p),
      hoverColor: C.panelAlt,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: C.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [st.color, st.color.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(st.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: C.text)),
                        Text(sub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: C.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(p.sku.isEmpty ? '—' : p.sku,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: C.accent)),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: st.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(p.category,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: st.color)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text('${p.quantity}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: p.isIn ? C.text : p.statusColor)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fill.toDouble(),
                        minHeight: 5,
                        backgroundColor: C.border,
                        valueColor: AlwaysStoppedAnimation(p.statusColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(rwf(p.price),
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: C.text)),
            ),
            Expanded(
              flex: 2,
              child: Align(
                  alignment: Alignment.centerLeft, child: _statusPill(p)),
            ),
            SizedBox(
              width: 132,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => editProduct(p),
                    icon: const Icon(Icons.edit_outlined,
                        size: 19, color: C.muted),
                  ),
                  IconButton(
                    tooltip: 'View details',
                    onPressed: () => viewProduct(p),
                    icon: const Icon(Icons.visibility_outlined,
                        size: 19, color: C.muted),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    color: Colors.white,
                    shape: _popupShape,
                    icon: const Icon(Icons.more_vert_rounded,
                        size: 20, color: C.muted),
                    onSelected: (v) {
                      if (v == 'edit') editProduct(p);
                      if (v == 'clone') cloneProduct(p);
                      if (v == 'add') adjustStock('add', preset: p);
                      if (v == 'remove') adjustStock('remove', preset: p);
                      if (v == 'delete') deleteProduct(p);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_outlined, size: 18, color: C.muted),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'clone',
                        child: Row(children: [
                          Icon(Icons.copy_rounded, size: 18, color: C.muted),
                          SizedBox(width: 12),
                          Text('Clone'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'add',
                        child: Row(children: [
                          Icon(Icons.add_circle_outline_rounded,
                              size: 18, color: C.green),
                          SizedBox(width: 12),
                          Text('Add stock'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'remove',
                        child: Row(children: [
                          Icon(Icons.remove_circle_outline_rounded,
                              size: 18, color: C.orange),
                          SizedBox(width: 12),
                          Text('Remove items'),
                        ]),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: C.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: C.red)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageBtn(Widget child, VoidCallback? onTap, {bool selected = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? C.accent : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? C.accent : C.border),
        ),
        child: child,
      ),
    );
  }

  Widget _footer(int total, int start, int end, int pages, int pg) {
    int from = math.max(0, pg - 2);
    int to = math.min(pages, from + 5);
    from = math.max(0, to - 5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: C.panelAlt,
        border: Border(top: BorderSide(color: C.border)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        spacing: 20,
        children: [
          Text(
            total == 0
                ? 'No products to display'
                : 'Displaying product ${start + 1}-$end of $total in total',
            style: const TextStyle(fontSize: 13, color: C.muted),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pageBtn(
                  Icon(Icons.chevron_left_rounded,
                      size: 20, color: pg > 0 ? C.text : C.border),
                  pg > 0 ? () => setState(() => page = pg - 1) : null),
              const SizedBox(width: 6),
              for (int i = from; i < to; i++) ...[
                _pageBtn(
                  Text('${i + 1}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: i == pg ? Colors.white : C.text)),
                  () => setState(() => page = i),
                  selected: i == pg,
                ),
                const SizedBox(width: 6),
              ],
              _pageBtn(
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: pg < pages - 1 ? C.text : C.border),
                  pg < pages - 1 ? () => setState(() => page = pg + 1) : null),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rows per page',
                  style: TextStyle(fontSize: 13, color: C.muted)),
              const SizedBox(width: 10),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: C.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: rows,
                    style: const TextStyle(fontSize: 13, color: C.text),
                    items: [
                      for (final n in const [5, 10, 20, 50])
                        DropdownMenuItem(value: n, child: Text('$n')),
                    ],
                    onChanged: (v) => setState(() {
                      rows = v ?? 10;
                      page = 0;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState({required bool noProducts}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [Color(0xFF60A5FA), C.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Icon(
                noProducts
                    ? Icons.inventory_2_rounded
                    : Icons.search_off_rounded,
                color: Colors.white,
                size: 40),
          ),
          const SizedBox(height: 18),
          Text(noProducts ? 'No products yet' : 'No products match your search',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: C.text)),
          const SizedBox(height: 6),
          Text(
              noProducts
                  ? 'Add your first product to start managing your stock.'
                  : 'Try another name, category, SKU or filter.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: C.muted)),
          if (noProducts) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: addProduct,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Product'),
              style: FilledButton.styleFrom(
                backgroundColor: C.accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.products;
    final list = filtered;
    final total = list.length;
    final pages = math.max(1, (total / rows).ceil());
    final pg = page.clamp(0, pages - 1).toInt();
    final start = pg * rows;
    final end = math.min(total, start + rows);
    final visible = list.sublist(start, end);

    final retail = all.fold<int>(0, (a, p) => a + p.price * p.quantity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth > 900;
              final tableW = math.max(box.maxWidth, 1000.0);

              final toolbar = wide
                  ? Row(
                      children: [
                        _tabs(all),
                        const Spacer(),
                        SizedBox(width: 300, child: _searchField()),
                        const SizedBox(width: 10),
                        _filtersButton(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _tabs(all)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _searchField()),
                            const SizedBox(width: 10),
                            _filtersButton(),
                          ],
                        ),
                      ],
                    );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Products',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: C.text)),
                          SizedBox(height: 4),
                          Text('Manage your products and stock easily',
                              style: TextStyle(color: C.muted, fontSize: 14)),
                        ],
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _manageStockButton(),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => toast(
                                'Import will be added in a later step.'),
                            child: _toolButton(Icons.upload_rounded, 'Import'),
                          ),
                          FilledButton.icon(
                            onPressed: addProduct,
                            icon: const Icon(Icons.add_rounded, size: 19),
                            label: const Text('New Product'),
                            style: FilledButton.styleFrom(
                              backgroundColor: C.accent,
                              minimumSize: const Size(0, 44),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  gridWrap(box.maxWidth, [
                    _miniStat(Icons.inventory_2_rounded, C.accent,
                        'Total Products', '${all.length}'),
                    _miniStat(Icons.payments_rounded, C.green, 'Stock Value',
                        rwf(retail)),
                    _miniStat(Icons.trending_down_rounded, C.orange,
                        'Low Stock', '${all.where((p) => p.isLow).length}'),
                    _miniStat(Icons.error_outline_rounded, C.red,
                        'Out of Stock', '${all.where((p) => p.isOut).length}'),
                  ], 4, 220),
                  const SizedBox(height: 16),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: C.border),
                      boxShadow: [
                        BoxShadow(
                          color: C.navy.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: toolbar,
                        ),
                        if (all.isEmpty)
                          _emptyState(noProducts: true)
                        else ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: tableW,
                              child: Column(
                                children: [
                                  Container(
                                    color: C.panelAlt,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    child: Row(
                                      children: [
                                        _th('Product', 4, sortKeyName: 'name'),
                                        _th('SKU', 2),
                                        _th('Category', 2),
                                        _th('Stock', 2, sortKeyName: 'stock'),
                                        _th('Price', 2, sortKeyName: 'price'),
                                        _th('Status', 2),
                                        const SizedBox(
                                          width: 132,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 14),
                                              child: Text('Action',
                                                  style: TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: C.muted)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (visible.isEmpty)
                                    SizedBox(
                                        width: tableW,
                                        child:
                                            _emptyState(noProducts: false))
                                  else
                                    for (final p in visible) _row(p),
                                ],
                              ),
                            ),
                          ),
                          _footer(total, start, end, pages, pg),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Add / Edit product form ─────────────────────────
class ProductFormDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> usedSkus;
  final Product? product;

  const ProductFormDialog({
    super.key,
    required this.categories,
    this.usedSkus = const [],
    this.product,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController name, sku, supplier, cost, price, qty, low;
  late String category;

  bool get editing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    name = TextEditingController(text: p?.name ?? '');
    sku = TextEditingController(text: p?.sku ?? '');
    supplier = TextEditingController(text: p?.supplier ?? '');
    cost = TextEditingController(
        text: (p == null || p.costPrice == 0) ? '' : '${p.costPrice}');
    price = TextEditingController(text: p == null ? '' : '${p.price}');
    qty = TextEditingController(text: p == null ? '' : '${p.quantity}');
    low = TextEditingController(text: p == null ? '5' : '${p.lowLevel}');
    category = p?.category ?? widget.categories.first;
  }

  @override
  void dispose() {
    for (final c in [name, sku, supplier, cost, price, qty, low]) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration _dec(String label, {IconData? icon, String? suffix}) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      prefixIcon: icon == null ? null : Icon(icon, size: 20, color: C.muted),
      filled: true,
      fillColor: C.panelAlt,
      border: b(Colors.transparent),
      enabledBorder: b(Colors.transparent),
      focusedBorder: b(C.accent, 1.5),
      errorBorder: b(C.red),
      focusedErrorBorder: b(C.red, 1.5),
    );
  }

  Widget _num(TextEditingController c, String label, IconData icon,
      {String? suffix, bool required = true, bool positive = false}) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _dec(label, icon: icon, suffix: suffix),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return required ? 'Required' : null;
        final n = int.tryParse(v);
        if (n == null) return 'Invalid number';
        if (positive && n <= 0) return 'Must be more than 0';
        return null;
      },
    );
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      Product(
        name: name.text.trim(),
        sku: sku.text.trim(),
        category: category,
        supplier: supplier.text.trim(),
        costPrice: int.tryParse(cost.text) ?? 0,
        price: int.parse(price.text),
        quantity: int.parse(qty.text),
        lowLevel: int.tryParse(low.text) ?? 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF60A5FA), C.accent]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                          editing
                              ? Icons.edit_rounded
                              : Icons.add_box_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(editing ? 'Edit Product' : 'New Product',
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: C.text)),
                          const Text('Fill in the product details below',
                              style:
                                  TextStyle(fontSize: 12.5, color: C.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: C.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: name,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec('Product name',
                            icon: Icons.label_outline_rounded),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: sku,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _dec('SKU (auto)',
                            icon: Icons.qr_code_2_rounded),
                        validator: (v) {
                          final t = (v ?? '').trim().toUpperCase();
                          if (t.isEmpty) return null;
                          final used =
                              widget.usedSkus.map((e) => e.toUpperCase());
                          return used.contains(t) ? 'SKU already used' : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: category,
                        isExpanded: true,
                        decoration:
                            _dec('Category', icon: Icons.category_outlined),
                        items: [
                          for (final c in widget.categories)
                            DropdownMenuItem(
                              value: c,
                              child: Row(children: [
                                Icon(catStyle(c).icon,
                                    size: 18, color: catStyle(c).color),
                                const SizedBox(width: 8),
                                Text(c),
                              ]),
                            ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => category = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: supplier,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec('Supplier (optional)',
                            icon: Icons.local_shipping_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: _num(cost, 'Cost price', Icons.sell_outlined,
                            suffix: 'RWF', required: false)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _num(
                            price, 'Selling price', Icons.payments_outlined,
                            suffix: 'RWF', positive: true)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child:
                            _num(qty, 'Quantity', Icons.inventory_2_outlined)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _num(low, 'Low stock alert at',
                            Icons.warning_amber_rounded)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(editing ? 'Save Changes' : 'Save Product'),
                      style: FilledButton.styleFrom(
                        backgroundColor: C.accent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Add / Remove stock dialog ─────────────────────────
class StockAdjustDialog extends StatefulWidget {
  final List<Product> products;
  final String mode; // 'add' or 'remove'
  final Product? initial;

  const StockAdjustDialog({
    super.key,
    required this.products,
    required this.mode,
    this.initial,
  });

  @override
  State<StockAdjustDialog> createState() => _StockAdjustDialogState();
}

class _StockAdjustDialogState extends State<StockAdjustDialog> {
  final _form = GlobalKey<FormState>();
  final qty = TextEditingController();
  late Product selected;

  bool get adding => widget.mode == 'add';

  @override
  void initState() {
    super.initState();
    selected = widget.initial ?? widget.products.first;
  }

  @override
  void dispose() {
    qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = adding ? C.green : C.orange;
    final n = int.tryParse(qty.text) ?? 0;
    final preview = math.max(0, selected.quantity + (adding ? n : -n));

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                          adding
                              ? Icons.add_circle_outline_rounded
                              : Icons.remove_circle_outline_rounded,
                          color: color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(adding ? 'Add Stock' : 'Remove Items',
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: C.text)),
                          Text(
                              adding
                                  ? 'Record goods received'
                                  : 'Record damaged, expired or used items',
                              style: const TextStyle(
                                  fontSize: 12.5, color: C.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: C.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Product>(
                  value: selected,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Product',
                    filled: true,
                    fillColor: C.panelAlt,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  items: [
                    for (final p in widget.products)
                      DropdownMenuItem(
                        value: p,
                        child: Text('${p.name}  •  ${p.quantity} on hand',
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => selected = v);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: qty,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    filled: true,
                    fillColor: C.panelAlt,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  validator: (v) {
                    final q = int.tryParse(v ?? '');
                    if (q == null || q <= 0) return 'Enter a quantity';
                    if (!adding && q > selected.quantity) {
                      return 'Only ${selected.quantity} on hand';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text('Stock after update:',
                          style: TextStyle(color: color, fontSize: 13)),
                      const Spacer(),
                      Text('${selected.quantity} → $preview',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        if (!_form.currentState!.validate()) return;
                        final q = int.parse(qty.text);
                        Navigator.pop(
                            context, StockAdjust(selected, adding ? q : -q));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: adding ? C.green : C.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(adding ? 'Add Stock' : 'Remove Items'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Product details dialog ─────────────────────────
class ProductDetailsDialog extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;

  const ProductDetailsDialog(
      {super.key, required this.product, required this.onEdit});

  Widget _kv(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.panelAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: C.muted)),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: color ?? C.text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = product;
    final st = catStyle(p.category);
    final margin = p.costPrice > 0 ? p.price - p.costPrice : null;

    return Dialog(
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [st.color, st.color.withValues(alpha: 0.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(st.icon, color: Colors.white, size: 34),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(p.statusLabel,
                                style: TextStyle(
                                    color: p.statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: _kv('SKU', p.sku.isEmpty ? '—' : p.sku,
                              color: C.accent)),
                      const SizedBox(width: 10),
                      Expanded(child: _kv('Category', p.category)),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: _kv('Supplier',
                              p.supplier.isEmpty ? '—' : p.supplier)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _kv('In stock', '${p.quantity}',
                              color: p.statusColor)),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: _kv('Cost price',
                              p.costPrice == 0 ? '—' : rwf(p.costPrice))),
                      const SizedBox(width: 10),
                      Expanded(child: _kv('Selling price', rwf(p.price))),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: _kv(
                              'Profit per unit',
                              margin == null ? '—' : rwf(margin),
                              color: (margin ?? 0) >= 0 ? C.green : C.red)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _kv('Stock value', rwf(p.price * p.quantity))),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child:
                              _kv('Low stock alert at', '${p.lowLevel} units')),
                      const SizedBox(width: 10),
                      const Expanded(child: SizedBox()),
                    ]),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onEdit();
                          },
                          icon: const Icon(Icons.edit_rounded, size: 17),
                          label: const Text('Edit Product'),
                          style: FilledButton.styleFrom(
                            backgroundColor: C.accent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
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

// ───────────────────────── Reusable widgets ─────────────────────────
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Panel(
      {super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: C.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border),
      ),
      child: child,
    );
  }
}

class PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const PanelTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: C.blue),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBadge(
      {super.key, required this.icon, required this.color, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value, sub, note;
  final Color noteColor;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.sub,
    required this.note,
    required this.noteColor,
  });

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color),
          const SizedBox(height: 14),
          Text(label,
              style: const TextStyle(
                  color: C.muted, fontSize: 10.5, letterSpacing: 0.6)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: C.muted, fontSize: 11.5)),
          const SizedBox(height: 4),
          Text(note, style: TextStyle(color: noteColor, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class MiniStat {
  final String value, label;
  final Color color;
  const MiniStat(this.value, this.label, this.color);
}

class MiniStatsPanel extends StatelessWidget {
  final IconData icon;
  final String title, link;
  final List<MiniStat> stats;

  const MiniStatsPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.link,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: PanelTitle(icon: icon, title: title)),
              Text(link, style: const TextStyle(fontSize: 11.5)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (final s in stats)
                Expanded(
                  child: Column(
                    children: [
                      Text(s.value,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: s.color)),
                      const SizedBox(height: 3),
                      Text(s.label,
                          style: const TextStyle(
                              color: C.muted, fontSize: 10, letterSpacing: 0.5)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: C.muted, fontSize: 11.5)),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: C.muted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconBadge(icon: icon, color: color, size: 36),
        ],
      ),
    );
  }
}

class StockHealthBar extends StatelessWidget {
  final int inStock, low, out;
  const StockHealthBar(
      {super.key, required this.inStock, required this.low, required this.out});

  @override
  Widget build(BuildContext context) {
    final total = inStock + low + out;
    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text('STOCK HEALTH',
              style: TextStyle(color: C.muted, fontSize: 11, letterSpacing: 0.5)),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: total == 0
                    ? Container(color: C.border)
                    : Row(
                        children: [
                          if (inStock > 0)
                            Expanded(
                                flex: inStock,
                                child: Container(color: C.green)),
                          if (low > 0)
                            Expanded(
                                flex: low, child: Container(color: C.orange)),
                          if (out > 0)
                            Expanded(
                                flex: out, child: Container(color: C.red)),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          _legend(C.green, '$inStock', 'In Stock'),
          const SizedBox(width: 10),
          _legend(C.orange, '$low', 'Low'),
          const SizedBox(width: 10),
          _legend(C.red, '$out', 'Out'),
        ],
      ),
    );
  }

  Widget _legend(Color c, String n, String label) {
    return Row(
      children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(n,
            style:
                TextStyle(color: c, fontSize: 11.5, fontWeight: FontWeight.bold)),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(color: C.muted, fontSize: 11)),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const StatTile(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.panelAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: C.muted, fontSize: 10, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

class LegendRow extends StatelessWidget {
  final Color color;
  final String label, value;
  const LegendRow(this.color, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: C.muted, fontSize: 11.5))),
          Text(value,
              style:
                  const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ───────────────────────── Donut chart ─────────────────────────
class Seg {
  final double value;
  final Color color;
  const Seg(this.value, this.color);
}

class Donut extends StatelessWidget {
  final String centerValue, centerLabel;
  final List<Seg> segments;
  const Donut({
    super.key,
    required this.centerValue,
    required this.centerLabel,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
              size: const Size(120, 120), painter: _DonutPainter(segments)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerValue,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)),
              Text(centerLabel,
                  style: const TextStyle(color: C.muted, fontSize: 8.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Seg> segments;
  _DonutPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke,
        size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final total = segments.fold<double>(0, (a, s) => a + s.value);
    if (total == 0) {
      paint.color = C.border;
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }
    double start = -math.pi / 2;
    for (final s in segments) {
      if (s.value <= 0) continue;
      final sweep = s.value / total * math.pi * 2;
      paint.color = s.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.segments != segments;
}