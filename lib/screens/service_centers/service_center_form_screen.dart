import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/service_center.dart';
import '../../services/auth_service.dart';
import '../../services/service_center_service.dart';
import '../../widgets/responsive_layout.dart';

class ServiceCenterFormScreen extends StatefulWidget {
  final String? centerId;

  const ServiceCenterFormScreen({super.key, this.centerId});

  bool get isEditing => centerId != null;

  @override
  State<ServiceCenterFormScreen> createState() => _ServiceCenterFormScreenState();
}

class _ServiceCenterFormScreenState extends State<ServiceCenterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _centerService = ServiceCenterService();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  final _serviceTypeController = TextEditingController();

  bool _isPreferred = false;
  List<String> _serviceTypes = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    _serviceTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyId() async {
    final companyId = await _authService.getUserCompanyId();
    if (mounted) {
      setState(() => _companyId = companyId);
      if (widget.isEditing) _loadCenter();
    }
  }

  Future<void> _loadCenter() async {
    if (_companyId == null) return;
    setState(() => _isLoading = true);

    final center =
        await _centerService.getCenter(_companyId!, widget.centerId!);
    if (center != null && mounted) {
      _nameController.text = center.name;
      _addressController.text = center.address;
      _cityController.text = center.city ?? '';
      _stateController.text = center.state ?? '';
      _zipCodeController.text = center.zipCode ?? '';
      _phoneController.text = center.phone ?? '';
      _emailController.text = center.email ?? '';
      _websiteController.text = center.website ?? '';
      _notesController.text = center.notes ?? '';
      _isPreferred = center.isPreferred;
      _serviceTypes = List<String>.from(center.serviceTypes);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _addServiceType() {
    final type = _serviceTypeController.text.trim();
    if (type.isNotEmpty && !_serviceTypes.contains(type)) {
      setState(() {
        _serviceTypes.add(type);
        _serviceTypeController.clear();
      });
    }
  }

  void _removeServiceType(String type) {
    setState(() => _serviceTypes.remove(type));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _companyId == null) return;

    setState(() => _isSaving = true);

    final center = ServiceCenter(
      id: widget.centerId ?? '',
      companyId: _companyId!,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      zipCode: _zipCodeController.text.trim().isEmpty
          ? null
          : _zipCodeController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      serviceTypes: _serviceTypes,
      isPreferred: _isPreferred,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      if (widget.isEditing) {
        await _centerService.updateCenter(_companyId!, center);
      } else {
        await _centerService.addCenter(_companyId!, center);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Service center updated'
                : 'Service center added'),
          ),
        );
        context.go('/service-centers');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/service-centers'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          widget.isEditing
                              ? 'Edit Service Center'
                              : 'Add Service Center',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
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
                            'Center Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Center Name *',
                          required: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Address *',
                          required: true,
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _cityController,
                                label: 'City',
                              ),
                              const SizedBox(height: 16),
                              ResponsiveLayout(
                                mobile: Column(
                                  children: [
                                    _buildTextField(
                                      controller: _stateController,
                                      label: 'State',
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _zipCodeController,
                                      label: 'Zip Code',
                                    ),
                                  ],
                                ),
                                desktop: Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _stateController,
                                        label: 'State',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _zipCodeController,
                                        label: 'Zip Code',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _cityController,
                                  label: 'City',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _stateController,
                                  label: 'State',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _zipCodeController,
                                  label: 'Zip Code',
                                ),
                              ),
                            ],
                          ),
                        ),
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
                            'Contact Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _phoneController,
                                  label: 'Phone',
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _websiteController,
                          label: 'Website',
                          keyboardType: TextInputType.url,
                        ),
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
                            'Services & Preferences',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Mark as preferred service center',
                          child: SwitchListTile(
                            title: const Text('Preferred Service Center'),
                            subtitle: const Text(
                                'Mark this center as preferred for your fleet'),
                            value: _isPreferred,
                            onChanged: (val) =>
                                setState(() => _isPreferred = val),
                            secondary: Icon(
                              _isPreferred ? Icons.star : Icons.star_border,
                              color: _isPreferred ? Colors.amber : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Add service type',
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _serviceTypeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Service Type',
                                    hintText: 'e.g. Oil Change, Tire Service',
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (_) => _addServiceType(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Semantics(
                                button: true,
                                label: 'Add service type to list',
                                child: IconButton(
                                  onPressed: _addServiceType,
                                  icon: const Icon(Icons.add_circle),
                                  iconSize: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_serviceTypes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _serviceTypes.map((type) {
                              return Chip(
                                label: Text(type),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => _removeServiceType(type),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _notesController,
                          label: 'Notes',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Cancel',
                      child: OutlinedButton(
                        onPressed: () => context.go('/service-centers'),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      button: true,
                      label: widget.isEditing
                          ? 'Save changes'
                          : 'Add service center',
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                widget.isEditing
                                    ? 'Save Changes'
                                    : 'Add Center',
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Semantics(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: required
            ? (val) => val == null || val.isEmpty ? '$label is required' : null
            : null,
      ),
    );
  }
}
