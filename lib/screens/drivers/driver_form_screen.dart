import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/driver.dart';
import '../../services/auth_service.dart';
import '../../services/driver_service.dart';
import '../../widgets/responsive_layout.dart';

class DriverFormScreen extends StatefulWidget {
  final String? driverId;

  const DriverFormScreen({super.key, this.driverId});

  bool get isEditing => driverId != null;

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driverService = DriverService();
  final _authService = AuthService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseStateController = TextEditingController();

  String _status = 'active';
  DateTime? _licenseExpiry;
  final _licenseExpiryController = TextEditingController();
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _licenseStateController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyId() async {
    final companyId = await _authService.getUserCompanyId();
    if (mounted) {
      setState(() => _companyId = companyId);
      if (widget.isEditing) _loadDriver();
    }
  }

  Future<void> _loadDriver() async {
    if (_companyId == null) return;
    setState(() => _isLoading = true);

    final driver =
        await _driverService.getDriver(_companyId!, widget.driverId!);
    if (driver != null && mounted) {
      _firstNameController.text = driver.firstName;
      _lastNameController.text = driver.lastName;
      _emailController.text = driver.email;
      _phoneController.text = driver.phone ?? '';
      _licenseNumberController.text = driver.licenseNumber ?? '';
      _licenseStateController.text = driver.licenseState ?? '';
      _status = driver.status;
      _licenseExpiry = driver.licenseExpiry;
      if (_licenseExpiry != null) {
        _licenseExpiryController.text =
            '${_licenseExpiry!.month.toString().padLeft(2, '0')}/${_licenseExpiry!.day.toString().padLeft(2, '0')}/${_licenseExpiry!.year}';
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _licenseExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() {
        _licenseExpiry = date;
        _licenseExpiryController.text =
            '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _companyId == null) return;

    setState(() => _isSaving = true);

    final driver = Driver(
      id: widget.driverId ?? '',
      companyId: _companyId!,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim().isEmpty
          ? null
          : _licenseNumberController.text.trim(),
      licenseState: _licenseStateController.text.trim().isEmpty
          ? null
          : _licenseStateController.text.trim(),
      licenseExpiry: _licenseExpiry,
      status: _status,
    );

    try {
      if (widget.isEditing) {
        await _driverService.updateDriver(_companyId!, driver);
      } else {
        await _driverService.addDriver(_companyId!, driver);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Driver updated successfully'
                : 'Driver added successfully'),
          ),
        );
        context.go('/drivers');
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
                      onPressed: () => context.go('/drivers'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          widget.isEditing ? 'Edit Driver' : 'Add Driver',
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
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                required: true,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                required: true,
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _firstNameController,
                                  label: 'First Name',
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _lastNameController,
                                  label: 'Last Name',
                                  required: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                                required: true,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone',
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  required: true,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _phoneController,
                                  label: 'Phone',
                                  keyboardType: TextInputType.phone,
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
                            'License Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _licenseNumberController,
                                label: 'License Number',
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _licenseStateController,
                                label: 'License State',
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _licenseNumberController,
                                  label: 'License Number',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _licenseStateController,
                                  label: 'License State',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'License expiry date',
                          child: TextFormField(
                            controller: _licenseExpiryController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'License Expiry Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Driver status',
                          child: DropdownButtonFormField<String>(
                            initialValue: _status,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'active', child: Text('Active')),
                              DropdownMenuItem(
                                  value: 'inactive', child: Text('Inactive')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _status = val);
                            },
                          ),
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
                      label: 'Cancel and go back to drivers',
                      child: OutlinedButton(
                        onPressed: () => context.go('/drivers'),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      button: true,
                      label: widget.isEditing
                          ? 'Save changes to driver'
                          : 'Add new driver',
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : Text(
                                widget.isEditing ? 'Save Changes' : 'Add Driver',
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
  }) {
    return Semantics(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (val) => val == null || val.isEmpty ? '$label is required' : null
            : null,
      ),
    );
  }
}
