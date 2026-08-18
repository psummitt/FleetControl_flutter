import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/vehicle.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_layout.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final _vehicleService = VehicleService();
  final _authService = AuthService();
  final _searchController = TextEditingController();
  String? _companyId;
  String _statusFilter = 'all';
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
      label: 'Vehicle List',
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
                      'Vehicles',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Add new vehicle',
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/vehicles/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Vehicle'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFilters(context),
            const SizedBox(height: 16),
            Expanded(child: _buildVehicleList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return isMobile
        ? Column(
            children: [
              _buildSearchField(context),
              const SizedBox(height: 12),
              _buildStatusFilter(context),
            ],
          )
        : Row(
            children: [
              Expanded(flex: 3, child: _buildSearchField(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusFilter(context)),
            ],
          );
  }

  Widget _buildSearchField(BuildContext context) {
    return Semantics(
      label: 'Search vehicles by name, make, or model',
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search vehicles',
          hintText: 'Search by name, make, or model...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return Semantics(
      label: 'Filter by vehicle status',
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'all', label: Text('All')),
          ButtonSegment(value: 'active', label: Text('Active')),
          ButtonSegment(value: 'maintenance', label: Text('Maintenance')),
          ButtonSegment(value: 'retired', label: Text('Retired')),
        ],
        selected: {_statusFilter},
        onSelectionChanged: (val) => setState(() => _statusFilter = val.first),
      ),
    );
  }

  Widget _buildVehicleList(BuildContext context) {
    return StreamBuilder<List<Vehicle>>(
      stream: _vehicleService.getVehicles(_companyId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var vehicles = snapshot.data ?? [];

        if (_statusFilter != 'all') {
          vehicles =
              vehicles.where((v) => v.status == _statusFilter).toList();
        }

        if (_searchQuery.isNotEmpty) {
          vehicles = vehicles
              .where((v) =>
                  v.displayName.toLowerCase().contains(_searchQuery) ||
                  v.make.toLowerCase().contains(_searchQuery) ||
                  v.model.toLowerCase().contains(_searchQuery) ||
                  (v.vin?.toLowerCase().contains(_searchQuery) ?? false))
              .toList();
        }

        if (vehicles.isEmpty) {
          return EmptyState(
            icon: Icons.directions_car,
            title: 'No vehicles found',
            message: _searchQuery.isNotEmpty || _statusFilter != 'all'
                ? 'Try adjusting your search or filters'
                : 'Add your first vehicle to get started',
            actionLabel: _searchQuery.isEmpty && _statusFilter == 'all'
                ? 'Add Vehicle'
                : null,
            onAction: _searchQuery.isEmpty && _statusFilter == 'all'
                ? () => context.go('/vehicles/new')
                : null,
          );
        }

        return ResponsiveLayout(
          mobile: _buildVehicleListView(context, vehicles),
          desktop: _buildVehicleGridView(context, vehicles),
        );
      },
    );
  }

  Widget _buildVehicleListView(BuildContext context, List<Vehicle> vehicles) {
    return ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleListTile(context, vehicle);
      },
    );
  }

  Widget _buildVehicleGridView(BuildContext context, List<Vehicle> vehicles) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(context, vehicle);
      },
    );
  }

  Widget _buildVehicleListTile(BuildContext context, Vehicle vehicle) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(vehicle.status),
          child: Icon(
            Icons.directions_car,
            color: Colors.white,
          ),
        ),
        title: Semantics(
          label: '${vehicle.displayName}, ${vehicle.status}',
          child: Text(vehicle.displayName),
        ),
        subtitle: Text(
          '${vehicle.licenseState ?? ''} ${vehicle.licenseNumber ?? ''} | ${vehicle.odometer} mi',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(vehicle.status),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.go('/vehicles/${vehicle.id}'),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    return Semantics(
      button: true,
      label: '${vehicle.displayName}, status: ${vehicle.status}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/vehicles/${vehicle.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _statusColor(vehicle.status),
                  child: const Icon(Icons.directions_car, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        vehicle.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${vehicle.licenseState ?? ''} ${vehicle.licenseNumber ?? ''} | ${vehicle.odometer} mi',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(vehicle.status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusColor(status);
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
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

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'retired':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
