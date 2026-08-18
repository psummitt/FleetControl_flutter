import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/driver_service.dart';
import '../../services/maintenance_service.dart';
import '../../services/service_center_service.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _companyId;
  bool _isError = false;
  final _vehicleService = VehicleService();
  final _driverService = DriverService();
  final _maintenanceService = MaintenanceService();
  final _serviceCenterService = ServiceCenterService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  Future<void> _loadCompanyId() async {
    try {
      final companyId = await _authService.getUserCompanyId().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timed out loading profile'),
      );
      if (mounted) {
        setState(() {
          _companyId = companyId;
          _isError = companyId == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isError = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Could not load user profile.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isError = false;
                  _companyId = null;
                });
                _loadCompanyId();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => _authService.signOut(),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
    }

    if (_companyId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Semantics(
      label: 'FleetControl Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Overview of your fleet operations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            _buildStatsGrid(context),
            const SizedBox(height: 32),
            _buildQuickActions(context),
            const SizedBox(height: 32),
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return StreamBuilder<List<dynamic>>(
      stream: _vehicleService.getVehicles(_companyId!),
      builder: (context, vehicleSnapshot) {
        final vehicles = vehicleSnapshot.data ?? [];
        final activeVehicles =
            vehicles.where((v) => v.status == 'active').length;
        final maintenanceVehicles =
            vehicles.where((v) => v.status == 'maintenance').length;

        return StreamBuilder<List<dynamic>>(
          stream: _driverService.getDrivers(_companyId!),
          builder: (context, driverSnapshot) {
            final drivers = driverSnapshot.data ?? [];
            final activeDrivers =
                drivers.where((d) => d.status == 'active').length;

            return StreamBuilder<List<dynamic>>(
              stream: _maintenanceService.getOverdueMaintenance(_companyId!),
              builder: (context, maintenanceSnapshot) {
                final overdue = (maintenanceSnapshot.data ?? []).length;

                return StreamBuilder<List<dynamic>>(
                  stream: _serviceCenterService.getServiceCenters(_companyId!),
                  builder: (context, centerSnapshot) {
                    final _ = (centerSnapshot.data ?? []).length;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: isMobile
                              ? double.infinity
                              : (MediaQuery.of(context).size.width - 80) / 4,
                          child: StatCard(
                            title: 'Total Vehicles',
                            value: vehicles.length.toString(),
                            icon: Icons.directions_car,
                            subtitle: '$activeVehicles active',
                            onTap: () => context.go('/vehicles'),
                          ),
                        ),
                        SizedBox(
                          width: isMobile
                              ? double.infinity
                              : (MediaQuery.of(context).size.width - 80) / 4,
                          child: StatCard(
                            title: 'Active Drivers',
                            value: activeDrivers.toString(),
                            icon: Icons.people,
                            subtitle: '${drivers.length} total',
                            onTap: () => context.go('/drivers'),
                          ),
                        ),
                        SizedBox(
                          width: isMobile
                              ? double.infinity
                              : (MediaQuery.of(context).size.width - 80) / 4,
                          child: StatCard(
                            title: 'In Maintenance',
                            value: maintenanceVehicles.toString(),
                            icon: Icons.build,
                            color: maintenanceVehicles > 0
                                ? Colors.orange
                                : Theme.of(context).colorScheme.primary,
                            onTap: () => context.go('/vehicles'),
                          ),
                        ),
                        SizedBox(
                          width: isMobile
                              ? double.infinity
                              : (MediaQuery.of(context).size.width - 80) / 4,
                          child: StatCard(
                            title: 'Overdue Service',
                            value: overdue.toString(),
                            icon: Icons.warning_amber,
                            color: overdue > 0
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                            onTap: () => context.go('/maintenance'),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Semantics(
      label: 'Quick actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionChip(
                context,
                icon: Icons.add_circle_outline,
                label: 'Add Vehicle',
                onTap: () => context.go('/vehicles/new'),
              ),
              _buildActionChip(
                context,
                icon: Icons.person_add_outlined,
                label: 'Add Driver',
                onTap: () => context.go('/drivers/new'),
              ),
              _buildActionChip(
                context,
                icon: Icons.build_circle_outlined,
                label: 'Log Maintenance',
                onTap: () => context.go('/maintenance/new'),
              ),
              _buildActionChip(
                context,
                icon: Icons.location_city_outlined,
                label: 'Add Service Center',
                onTap: () => context.go('/service-centers/new'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: ActionChip(
        avatar: Icon(icon),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: _maintenanceService.getMaintenanceRecords(_companyId!),
      builder: (context, snapshot) {
        final records = (snapshot.data ?? []).take(5).toList();

        return Semantics(
          label: 'Recent maintenance activity',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Recent Maintenance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              if (records.isEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('No recent maintenance records'),
                    subtitle: const Text('Start logging vehicle maintenance'),
                    trailing: TextButton(
                      onPressed: () => context.go('/maintenance/new'),
                      child: const Text('Add Record'),
                    ),
                  ),
                )
              else
                ...records.map(
                  (record) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          record.type == 'oil_change'
                              ? Icons.oil_barrel
                              : record.type == 'tire'
                                  ? Icons.circle
                                  : record.type == 'brake'
                                      ? Icons.stop_circle
                                      : Icons.build,
                        ),
                      ),
                      title: Text(record.title),
                      subtitle: Text(
                        '${record.type.replaceAll('_', ' ').toUpperCase()} - \${record.cost.toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        _formatDate(record.serviceDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
