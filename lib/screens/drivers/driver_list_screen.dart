import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/driver.dart';
import '../../services/auth_service.dart';
import '../../services/driver_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/responsive_layout.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  final _driverService = DriverService();
  final _authService = AuthService();
  final _searchController = TextEditingController();
  String? _companyId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyId() async {
    final companyId = await _authService.getUserCompanyId();
    if (mounted) setState(() => _companyId = companyId);
  }

  @override
  Widget build(BuildContext context) {
    if (_companyId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Semantics(
      label: 'Driver List',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      'Drivers',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Add new driver',
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/drivers/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Driver'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Search drivers by name or email',
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search drivers',
                  hintText: 'Search by name or email...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildDriverList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverList() {
    return StreamBuilder<List<Driver>>(
      stream: _driverService.getDrivers(_companyId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var drivers = snapshot.data ?? [];

        if (_searchQuery.isNotEmpty) {
          drivers = drivers
              .where((d) =>
                  d.fullName.toLowerCase().contains(_searchQuery) ||
                  d.email.toLowerCase().contains(_searchQuery))
              .toList();
        }

        if (drivers.isEmpty) {
          return EmptyState(
            icon: Icons.people,
            title: 'No drivers found',
            message: _searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : 'Add your first driver to get started',
            actionLabel: _searchQuery.isEmpty ? 'Add Driver' : null,
            onAction: _searchQuery.isEmpty ? () => context.go('/drivers/new') : null,
          );
        }

        return ResponsiveLayout(
          mobile: _buildDriverListView(drivers),
          desktop: _buildDriverGridView(drivers),
        );
      },
    );
  }

  Widget _buildDriverListView(List<Driver> drivers) {
    return ListView.builder(
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(driver.fullName[0].toUpperCase()),
            ),
            title: Semantics(
              label: '${driver.fullName}, ${driver.status}',
              child: Text(driver.fullName),
            ),
            subtitle: Text(driver.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusChip(driver.status),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.go('/drivers/${driver.id}/edit');
                    } else if (value == 'delete') {
                      _deleteDriver(driver);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDriverGridView(List<Driver> drivers) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return Semantics(
          button: true,
          label: '${driver.fullName}, ${driver.status}',
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.go('/drivers/${driver.id}/edit'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      child: Text(
                        driver.fullName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            driver.fullName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            driver.email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatusChip(driver.status),
                        const SizedBox(height: 4),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              context.go('/drivers/${driver.id}/edit');
                            } else if (value == 'delete') {
                              _deleteDriver(driver);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    final color = status == 'active' ? Colors.green : Colors.grey;
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Future<void> _deleteDriver(Driver driver) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Driver',
      message:
          'Are you sure you want to delete ${driver.fullName}? This action cannot be undone.',
    );

    if (confirmed && mounted) {
      await _driverService.deleteDriver(_companyId!, driver.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${driver.fullName} deleted')),
        );
      }
    }
  }
}
