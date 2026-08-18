import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'responsive_layout.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return _AppScaffoldWithNav(child: child);
  }
}

class _AppScaffoldWithNav extends StatefulWidget {
  final Widget child;
  const _AppScaffoldWithNav({required this.child});

  @override
  State<_AppScaffoldWithNav> createState() => _AppScaffoldWithNavState();
}

class _AppScaffoldWithNavState extends State<_AppScaffoldWithNav> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', '/dashboard'),
    _NavItem(Icons.directions_car_outlined, Icons.directions_car, 'Vehicles', '/vehicles'),
    _NavItem(Icons.people_outlined, Icons.people, 'Drivers', '/drivers'),
    _NavItem(Icons.build_outlined, Icons.build, 'Maintenance', '/maintenance'),
    _NavItem(Icons.location_city_outlined, Icons.location_city, 'Service Centers', '/service-centers'),
    _NavItem(Icons.assessment_outlined, Icons.assessment, 'Reports', '/reports'),
    _NavItem(Icons.settings_outlined, Icons.settings, 'Settings', '/settings'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].route)) {
        if (_selectedIndex != i) {
          setState(() => _selectedIndex = i);
        }
        break;
      }
    }
  }

  void _onNavigate(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index].route);
    if (ResponsiveLayout.isMobile(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final user = FirebaseAuth.instance.currentUser;

    return Semantics(
      label: 'FleetControl Application',
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            header: true,
            child: const Text('FleetControl'),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            if (user != null)
              Semantics(
                button: true,
                label: 'Sign out',
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await FirebaseAuth.instance.signOut();
                    }
                  },
                ),
              ),
          ],
        ),
        drawer: isMobile ? _buildDrawer(context) : null,
        body: Row(
          children: [
            if (!isMobile) _buildSidebar(context),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Semantics(
              header: true,
              child: Text(user?.displayName ?? 'FleetControl User'),
            ),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              child: Text(
                (user?.email ?? 'U')[0].toUpperCase(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (var i = 0; i < _navItems.length; i++)
                  Semantics(
                    button: true,
                    selected: _selectedIndex == i,
                    label: _navItems[i].label,
                    child: ListTile(
                      leading: Icon(_selectedIndex == i
                          ? _navItems[i].selectedIcon
                          : _navItems[i].icon),
                      title: Text(_navItems[i].label),
                      selected: _selectedIndex == i,
                      onTap: () => _onNavigate(i),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).pop();
              showAboutDialog(
                context: context,
                applicationName: 'FleetControl',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.directions_car, size: 48),
                children: const [
                  Text('Fleet management application for tracking vehicles, drivers, and maintenance.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final screenWidth = ResponsiveLayout.screenWidth(context);
    final isNarrow = screenWidth < 1024;

    return Container(
      width: isNarrow ? 72 : 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ...List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final isSelected = _selectedIndex == i;
            return Semantics(
              button: true,
              selected: isSelected,
              label: item.label,
              child: Tooltip(
                message: isNarrow ? item.label : '',
                child: ListTile(
                  leading: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: isNarrow
                      ? null
                      : Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                  selected: isSelected,
                  selectedTileColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  onTap: () => _onNavigate(i),
                ),
              ),
            );
          }),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isNarrow
                ? const Icon(Icons.info_outline, size: 20)
                : const ListTile(
                    leading: Icon(Icons.info_outline, size: 20),
                    title: Text('v1.0.0', style: TextStyle(fontSize: 12)),
                    dense: true,
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavItem(this.icon, this.selectedIcon, this.label, this.route);
}
