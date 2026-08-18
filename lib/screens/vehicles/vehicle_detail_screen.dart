import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/vehicle.dart';
import '../../models/maintenance_record.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/maintenance_service.dart';
import '../../widgets/confirm_dialog.dart';
import 'package:intl/intl.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final _vehicleService = VehicleService();
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

    return StreamBuilder<Vehicle?>(
      stream: Stream.fromFuture(
          _vehicleService.getVehicle(_companyId!, widget.vehicleId)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vehicle = snapshot.data;
        if (vehicle == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                const Text('Vehicle not found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/vehicles'),
                  child: const Text('Back to Vehicles'),
                ),
              ],
            ),
          );
        }

        return _buildVehicleDetail(context, vehicle);
      },
    );
  }

  Widget _buildVehicleDetail(BuildContext context, Vehicle vehicle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/vehicles'),
                tooltip: 'Back to vehicles',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    vehicle.displayName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              _buildStatusChip(vehicle.status),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Edit vehicle',
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      context.go('/vehicles/${vehicle.id}/edit'),
                  tooltip: 'Edit vehicle',
                ),
              ),
              Semantics(
                button: true,
                label: 'Delete vehicle',
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteVehicle(context, vehicle),
                  tooltip: 'Delete vehicle',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Vehicle Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, 'Year', vehicle.year.toString()),
                  _buildInfoRow(context, 'Make', vehicle.make),
                  _buildInfoRow(context, 'Model', vehicle.model),
                  _buildInfoRow(context, 'Color', vehicle.color ?? 'Not specified'),
                  if (vehicle.vin != null && vehicle.vin!.isNotEmpty)
                    _buildInfoRow(context, 'VIN', vehicle.vin!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Registration & Keys',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, 'License State',
                      vehicle.licenseState ?? 'Not specified'),
                  _buildInfoRow(context, 'License Number',
                      vehicle.licenseNumber ?? 'Not specified'),
                  _buildInfoRow(context, 'Key - Ignition',
                      vehicle.keyIgnition ?? 'Not specified'),
                  _buildInfoRow(
                      context, 'Key - Door', vehicle.keyDoor ?? 'Not specified'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Purchase Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, 'Odometer',
                      '${NumberFormat.decimalPattern().format(vehicle.odometer)} miles'),
                  _buildInfoRow(
                      context,
                      'Purchase Date',
                      vehicle.purchaseDate != null
                          ? _dateFormat.format(vehicle.purchaseDate!)
                          : 'Not specified'),
                  _buildInfoRow(
                      context,
                      'Purchase Price',
                      vehicle.purchasePrice != null
                          ? NumberFormat.currency(symbol: '\$')
                              .format(vehicle.purchasePrice)
                          : 'Not specified'),
                  if (vehicle.notes != null && vehicle.notes!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(vehicle.notes!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildMaintenanceHistory(context, vehicle),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(
            child: Semantics(
              label: '$label: $value',
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceHistory(BuildContext context, Vehicle vehicle) {
    return StreamBuilder<List<MaintenanceRecord>>(
      stream: _maintenanceService.getMaintenanceByVehicle(
          _companyId!, vehicle.id),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];

        return Card(
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
                          'Maintenance History',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Add maintenance record',
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => context.go('/maintenance/new'),
                        tooltip: 'Add maintenance record',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (records.isEmpty)
                  const Text('No maintenance records for this vehicle.')
                else
                  ...records.map(
                    (record) => ListTile(
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
                        '${record.type.replaceAll('_', ' ').toUpperCase()} - \$${record.cost.toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        _dateFormat.format(record.serviceDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'maintenance':
        color = Colors.orange;
        break;
      case 'retired':
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }

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

  final _dateFormat = DateFormat.yMMMd();

  Future<void> _deleteVehicle(BuildContext context, Vehicle vehicle) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Vehicle',
      message:
          'Are you sure you want to delete ${vehicle.displayName}? This action cannot be undone.',
    );

    if (confirmed && context.mounted) {
      await _vehicleService.deleteVehicle(_companyId!, vehicle.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${vehicle.displayName} deleted')),
        );
        context.go('/vehicles');
      }
    }
  }
}
