import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/service_center.dart';
import '../../services/auth_service.dart';
import '../../services/service_center_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/responsive_layout.dart';

class ServiceCenterListScreen extends StatefulWidget {
  const ServiceCenterListScreen({super.key});

  @override
  State<ServiceCenterListScreen> createState() =>
      _ServiceCenterListScreenState();
}

class _ServiceCenterListScreenState extends State<ServiceCenterListScreen> {
  final _centerService = ServiceCenterService();
  final _authService = AuthService();
  final _searchController = TextEditingController();
  String? _companyId;
  String _searchQuery = '';
  bool _showPreferredOnly = false;

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
      label: 'Service Centers',
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
                      'Service Centers',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Add new service center',
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/service-centers/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Center'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveLayout(
              mobile: Column(
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 12),
                  _buildFilterRow(),
                ],
              ),
              desktop: Row(
                children: [
                  Expanded(flex: 3, child: _buildSearchField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFilterRow()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildCenterList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Semantics(
      label: 'Search service centers',
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search service centers',
          hintText: 'Search by name, city, or service type...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Semantics(
      label: 'Filter service centers',
      child: Row(
        children: [
          FilterChip(
            label: const Text('Preferred Only'),
            selected: _showPreferredOnly,
            onSelected: (val) => setState(() => _showPreferredOnly = val),
            avatar: Icon(
              _showPreferredOnly ? Icons.star : Icons.star_border,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterList() {
    final stream = _showPreferredOnly
        ? _centerService.getPreferredCenters(_companyId!)
        : _centerService.getServiceCenters(_companyId!);

    return StreamBuilder<List<ServiceCenter>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var centers = snapshot.data ?? [];

        if (_searchQuery.isNotEmpty) {
          centers = centers
              .where((c) =>
                  c.name.toLowerCase().contains(_searchQuery) ||
                  (c.city?.toLowerCase().contains(_searchQuery) ?? false) ||
                  c.serviceTypes
                      .any((t) => t.toLowerCase().contains(_searchQuery)))
              .toList();
        }

        if (centers.isEmpty) {
          return EmptyState(
            icon: Icons.location_city,
            title: 'No service centers found',
            message: _searchQuery.isNotEmpty || _showPreferredOnly
                ? 'Try adjusting your search or filters'
                : 'Add your first service center',
            actionLabel:
                _searchQuery.isEmpty && !_showPreferredOnly ? 'Add Center' : null,
            onAction: _searchQuery.isEmpty && !_showPreferredOnly
                ? () => context.go('/service-centers/new')
                : null,
          );
        }

        return ResponsiveLayout(
          mobile: ListView.builder(
            itemCount: centers.length,
            itemBuilder: (context, index) =>
                _buildCenterTile(context, centers[index]),
          ),
          desktop: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: centers.length,
            itemBuilder: (context, index) =>
                _buildCenterCard(context, centers[index]),
          ),
        );
      },
    );
  }

  Widget _buildCenterTile(BuildContext context, ServiceCenter center) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: center.isPreferred ? Colors.amber : null,
          child: Icon(
            center.isPreferred ? Icons.star : Icons.location_city,
            color: center.isPreferred ? Colors.white : null,
          ),
        ),
        title: Semantics(
          label: '${center.name}${center.isPreferred ? ', preferred' : ''}',
          child: Text(center.name),
        ),
        subtitle: Text(
          center.fullAddress,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (center.phone != null)
              Semantics(
                button: true,
                label: 'Call ${center.name}',
                child: IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () {},
                  tooltip: 'Call',
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.go('/service-centers/${center.id}/edit');
                } else if (value == 'delete') {
                  _deleteCenter(center);
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

  Widget _buildCenterCard(BuildContext context, ServiceCenter center) {
    return Semantics(
      button: true,
      label: '${center.name}, ${center.fullAddress}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/service-centers/${center.id}/edit'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: center.isPreferred ? Colors.amber : null,
                      child: Icon(
                        center.isPreferred ? Icons.star : Icons.location_city,
                        color: center.isPreferred ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        center.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (center.isPreferred)
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  center.fullAddress,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (center.serviceTypes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: center.serviceTypes.take(3).map((type) {
                      return Chip(
                        label: Text(type, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCenter(ServiceCenter center) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Service Center',
      message:
          'Are you sure you want to delete "${center.name}"? This action cannot be undone.',
    );

    if (confirmed && mounted) {
      await _centerService.deleteCenter(_companyId!, center.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${center.name} deleted')),
        );
      }
    }
  }
}
