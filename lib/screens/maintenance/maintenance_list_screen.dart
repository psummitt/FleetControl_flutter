import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/maintenance_record.dart';
import '../../services/auth_service.dart';
import '../../services/maintenance_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/responsive_layout.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  final _maintenanceService = MaintenanceService();
  final _authService = AuthService();
  String? _companyId;
  String _filter = 'all';

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
      label: 'Maintenance Records',
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
                      'Maintenance',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Add maintenance record',
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/maintenance/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Record'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Filter maintenance records',
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'scheduled', label: Text('Scheduled')),
                  ButtonSegment(value: 'completed', label: Text('Completed')),
                  ButtonSegment(value: 'overdue', label: Text('Overdue')),
                ],
                selected: {_filter},
                onSelectionChanged: (val) =>
                    setState(() => _filter = val.first),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildMaintenanceList()),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceList() {
    Stream<List<MaintenanceRecord>> stream;
    switch (_filter) {
      case 'scheduled':
        stream = _maintenanceService.getUpcomingMaintenance(_companyId!);
        break;
      case 'overdue':
        stream = _maintenanceService.getOverdueMaintenance(_companyId!);
        break;
      default:
        stream = _maintenanceService.getMaintenanceRecords(_companyId!);
    }

    return StreamBuilder<List<MaintenanceRecord>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var records = snapshot.data ?? [];

        if (_filter == 'completed') {
          records = records.where((r) => r.isCompleted).toList();
        }

        if (records.isEmpty) {
          return EmptyState(
            icon: Icons.build,
            title: 'No maintenance records',
            message: _filter != 'all'
                ? 'No records match this filter'
                : 'Start logging vehicle maintenance',
            actionLabel: _filter == 'all' ? 'Add Record' : null,
            onAction: _filter == 'all' ? () => context.go('/maintenance/new') : null,
          );
        }

        final dateFormat = DateFormat.yMMMd();

        return ResponsiveLayout(
          mobile: ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildRecordTile(context, record, dateFormat);
            },
          ),
          desktop: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              childAspectRatio: 2.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildRecordCard(context, record, dateFormat);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecordTile(
      BuildContext context, MaintenanceRecord record, DateFormat dateFormat) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: record.isOverdue
              ? Theme.of(context).colorScheme.error
              : record.isScheduled
                  ? Colors.orange
                  : Colors.green,
          child: Icon(
            _typeIcon(record.type),
            color: Colors.white,
          ),
        ),
        title: Semantics(
          label:
              '${record.title}, ${record.type.replaceAll('_', ' ')}, status: ${record.status}',
          child: Text(record.title),
        ),
        subtitle: Text(
          '${record.type.replaceAll('_', ' ').toUpperCase()} | \$${record.cost.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateFormat.format(record.serviceDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (record.nextServiceDate != null)
                  Text(
                    'Next: ${dateFormat.format(record.nextServiceDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: record.isOverdue
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.go('/maintenance/${record.id}/edit');
                } else if (value == 'delete') {
                  _deleteRecord(record);
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
  }

  Widget _buildRecordCard(
      BuildContext context, MaintenanceRecord record, DateFormat dateFormat) {
    return Semantics(
      button: true,
      label:
          '${record.title}, ${record.type.replaceAll('_', ' ')}, ${record.status}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/maintenance/${record.id}/edit'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: record.isOverdue
                          ? Theme.of(context).colorScheme.error
                          : record.isScheduled
                              ? Colors.orange
                              : Colors.green,
                      child: Icon(_typeIcon(record.type), color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        record.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    _buildStatusChip(record.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${record.type.replaceAll('_', ' ').toUpperCase()} - \$${record.cost.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Service: ${dateFormat.format(record.serviceDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (record.nextServiceDate != null)
                  Text(
                    'Next: ${dateFormat.format(record.nextServiceDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: record.isOverdue
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'scheduled':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
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

  IconData _typeIcon(String type) {
    switch (type) {
      case 'oil_change':
        return Icons.oil_barrel;
      case 'tire':
        return Icons.circle;
      case 'brake':
        return Icons.stop_circle;
      case 'inspection':
        return Icons.search;
      case 'repair':
        return Icons.build;
      default:
        return Icons.build_circle;
    }
  }

  Future<void> _deleteRecord(MaintenanceRecord record) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Record',
      message:
          'Are you sure you want to delete "${record.title}"? This action cannot be undone.',
    );

    if (confirmed && mounted) {
      await _maintenanceService.deleteRecord(_companyId!, record.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted')),
        );
      }
    }
  }
}
