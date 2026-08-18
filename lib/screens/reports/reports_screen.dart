import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vehicle.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/driver_service.dart';
import '../../services/maintenance_service.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/stat_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _vehicleService = VehicleService();
  final _driverService = DriverService();
  final _maintenanceService = MaintenanceService();
  final _authService = AuthService();
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
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
      label: 'Reports',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Reports',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fleet analytics and performance overview',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            _buildFleetOverview(context),
            const SizedBox(height: 32),
            _buildMaintenanceReport(context),
            const SizedBox(height: 32),
            _buildVehicleConditionReport(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetOverview(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return StreamBuilder<List<dynamic>>(
      stream: _vehicleService.getVehicles(_companyId!),
      builder: (context, vehicleSnapshot) {
        final vehicles = vehicleSnapshot.data ?? [];

        return StreamBuilder<List<dynamic>>(
          stream: _driverService.getDrivers(_companyId!),
          builder: (context, driverSnapshot) {
            final drivers = driverSnapshot.data ?? [];

            final activeVehicles =
                vehicles.where((v) => v.status == 'active').length;
            final maintenanceVehicles =
                vehicles.where((v) => v.status == 'maintenance').length;
            final retiredVehicles =
                vehicles.where((v) => v.status == 'retired').length;
            final activeDrivers =
                drivers.where((d) => d.status == 'active').length;
            final assignedVehicles =
                vehicles.where((v) => v.assignedDriverId != null).length;
            final unassignedVehicles =
                vehicles.where((v) => v.assignedDriverId == null).length;

            return Semantics(
              label: 'Fleet overview statistics',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Fleet Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
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
                        ),
                      ),
                      SizedBox(
                        width: isMobile
                            ? double.infinity
                            : (MediaQuery.of(context).size.width - 80) / 4,
                        child: StatCard(
                          title: 'Assigned',
                          value: assignedVehicles.toString(),
                          icon: Icons.link,
                          color: Colors.green,
                          subtitle: '$unassignedVehicles unassigned',
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
                              : null,
                          subtitle: '$retiredVehicles retired',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMaintenanceReport(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: _maintenanceService.getMaintenanceRecords(_companyId!),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        final completedRecords =
            records.where((r) => r.status == 'completed').toList();
        final scheduledRecords =
            records.where((r) => r.status == 'scheduled').toList();
        final overdueRecords =
            records.where((r) => r.isOverdue).toList();

        double totalCost = 0;
        for (final record in completedRecords) {
          totalCost += record.cost;
        }

        final avgCost = completedRecords.isNotEmpty
            ? totalCost / completedRecords.length
            : 0.0;

        return Semantics(
          label: 'Maintenance report',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Maintenance Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildReportRow(
                        context,
                        'Total Records',
                        records.length.toString(),
                        Icons.build,
                      ),
                      const Divider(),
                      _buildReportRow(
                        context,
                        'Completed',
                        completedRecords.length.toString(),
                        Icons.check_circle,
                        valueColor: Colors.green,
                      ),
                      const Divider(),
                      _buildReportRow(
                        context,
                        'Scheduled',
                        scheduledRecords.length.toString(),
                        Icons.schedule,
                        valueColor: Colors.orange,
                      ),
                      const Divider(),
                      _buildReportRow(
                        context,
                        'Overdue',
                        overdueRecords.length.toString(),
                        Icons.warning_amber,
                        valueColor: overdueRecords.isNotEmpty
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                      const Divider(),
                      _buildReportRow(
                        context,
                        'Total Maintenance Cost',
                        '\$${totalCost.toStringAsFixed(2)}',
                        Icons.attach_money,
                        valueColor: Colors.green,
                      ),
                      const Divider(),
                      _buildReportRow(
                        context,
                        'Average Cost per Service',
                        '\$${avgCost.toStringAsFixed(2)}',
                        Icons.analytics,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehicleConditionReport(BuildContext context) {
    return StreamBuilder<List<Vehicle>>(
      stream: _vehicleService.getVehicles(_companyId!),
      builder: (context, snapshot) {
        final vehicles = snapshot.data ?? [];

        final makes = <String, int>{};
        for (final v in vehicles) {
          makes[v.make] = (makes[v.make] ?? 0) + 1;
        }

        int totalOdometer = 0;
        for (final v in vehicles) {
          totalOdometer += v.odometer;
        }
        final avgOdometer =
            vehicles.isNotEmpty ? totalOdometer / vehicles.length : 0;

        return Semantics(
          label: 'Vehicle condition report',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Vehicle Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (makes.isEmpty)
                        const Text('No vehicle data available')
                      else
                        ...makes.entries.map(
                          (entry) => Column(
                            children: [
                              _buildReportRow(
                                context,
                                entry.key,
                                '${entry.value} vehicle${entry.value > 1 ? 's' : ''}',
                                Icons.directions_car,
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      _buildReportRow(
                        context,
                        'Total Odometer (all vehicles)',
                        '${NumberFormat.decimalPattern().format(totalOdometer)} miles',
                        Icons.speed,
                      ),
                      const Divider(),
                      _buildReportRow(
                        context,
                        'Average Odometer',
                        '${avgOdometer.toStringAsFixed(0)} miles',
                        Icons.analytics,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Semantics(
            label: '$label: $value',
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
