import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/vehicle.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_service.dart';
import '../../widgets/responsive_layout.dart';

class VehicleFormScreen extends StatefulWidget {
  final String? vehicleId;

  const VehicleFormScreen({super.key, this.vehicleId});

  bool get isEditing => vehicleId != null;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleService = VehicleService();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _vinController = TextEditingController();
  final _licenseStateController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _colorController = TextEditingController();
  final _odometerController = TextEditingController();
  final _keyIgnitionController = TextEditingController();
  final _keyDoorController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _notesController = TextEditingController();

  String _status = 'active';
  DateTime? _purchaseDate;
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
    _yearController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _vinController.dispose();
    _licenseStateController.dispose();
    _licenseNumberController.dispose();
    _colorController.dispose();
    _odometerController.dispose();
    _keyIgnitionController.dispose();
    _keyDoorController.dispose();
    _purchaseDateController.dispose();
    _purchasePriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyId() async {
    final companyId = await _authService.getUserCompanyId();
    if (mounted) {
      setState(() => _companyId = companyId);
      if (widget.isEditing) {
        _loadVehicle();
      }
    }
  }

  Future<void> _loadVehicle() async {
    if (_companyId == null) return;
    setState(() => _isLoading = true);

    final vehicle =
        await _vehicleService.getVehicle(_companyId!, widget.vehicleId!);
    if (vehicle != null && mounted) {
      _nameController.text = vehicle.name;
      _yearController.text = vehicle.year.toString();
      _makeController.text = vehicle.make;
      _modelController.text = vehicle.model;
      _vinController.text = vehicle.vin ?? '';
      _licenseStateController.text = vehicle.licenseState ?? '';
      _licenseNumberController.text = vehicle.licenseNumber ?? '';
      _colorController.text = vehicle.color ?? '';
      _odometerController.text = vehicle.odometer.toString();
      _keyIgnitionController.text = vehicle.keyIgnition ?? '';
      _keyDoorController.text = vehicle.keyDoor ?? '';
      _purchasePriceController.text = vehicle.purchasePrice?.toString() ?? '';
      _notesController.text = vehicle.notes ?? '';
      _status = vehicle.status;
      _purchaseDate = vehicle.purchaseDate;
      if (_purchaseDate != null) {
        _purchaseDateController.text =
            '${_purchaseDate!.month.toString().padLeft(2, '0')}/${_purchaseDate!.day.toString().padLeft(2, '0')}/${_purchaseDate!.year}';
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _purchaseDate = date;
        _purchaseDateController.text =
            '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _companyId == null) return;

    setState(() => _isSaving = true);

    final vehicle = Vehicle(
      id: widget.vehicleId ?? '',
      companyId: _companyId!,
      name: _nameController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? 0,
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      vin: _vinController.text.trim().isEmpty ? null : _vinController.text.trim(),
      licenseState: _licenseStateController.text.trim().isEmpty
          ? null
          : _licenseStateController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim().isEmpty
          ? null
          : _licenseNumberController.text.trim(),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      odometer: int.tryParse(_odometerController.text.trim()) ?? 0,
      keyIgnition: _keyIgnitionController.text.trim().isEmpty
          ? null
          : _keyIgnitionController.text.trim(),
      keyDoor: _keyDoorController.text.trim().isEmpty
          ? null
          : _keyDoorController.text.trim(),
      purchaseDate: _purchaseDate,
      purchasePrice:
          double.tryParse(_purchasePriceController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      status: _status,
    );

    try {
      if (widget.isEditing) {
        await _vehicleService.updateVehicle(_companyId!, vehicle);
      } else {
        await _vehicleService.addVehicle(_companyId!, vehicle);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Vehicle updated successfully'
                : 'Vehicle added successfully'),
          ),
        );
        context.go('/vehicles');
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
                      onPressed: () => context.go('/vehicles'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          widget.isEditing ? 'Edit Vehicle' : 'Add Vehicle',
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
                            'Vehicle Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Vehicle Name',
                          hint: 'e.g. Truck 001',
                          required: true,
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _yearController,
                                label: 'Year',
                                hint: 'e.g. 2024',
                                required: true,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _makeController,
                                label: 'Make',
                                hint: 'e.g. Ford',
                                required: true,
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _yearController,
                                  label: 'Year',
                                  hint: 'e.g. 2024',
                                  required: true,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _makeController,
                                  label: 'Make',
                                  hint: 'e.g. Ford',
                                  required: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _modelController,
                          label: 'Model',
                          hint: 'e.g. F-150',
                          required: true,
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _vinController,
                                label: 'VIN',
                                hint: 'Vehicle Identification Number',
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _colorController,
                                label: 'Color',
                                hint: 'e.g. White',
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _vinController,
                                  label: 'VIN',
                                  hint: 'Vehicle Identification Number',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _colorController,
                                  label: 'Color',
                                  hint: 'e.g. White',
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
                            'Registration & Keys',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _licenseStateController,
                                label: 'License State',
                                hint: 'e.g. TX',
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _licenseNumberController,
                                label: 'License Number',
                                hint: 'e.g. ABC-1234',
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _licenseStateController,
                                  label: 'License State',
                                  hint: 'e.g. TX',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _licenseNumberController,
                                  label: 'License Number',
                                  hint: 'e.g. ABC-1234',
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
                                controller: _keyIgnitionController,
                                label: 'Ignition Key',
                                hint: 'Key code or ID',
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _keyDoorController,
                                label: 'Door Key',
                                hint: 'Key code or ID',
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _keyIgnitionController,
                                  label: 'Ignition Key',
                                  hint: 'Key code or ID',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _keyDoorController,
                                  label: 'Door Key',
                                  hint: 'Key code or ID',
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
                            'Purchase & Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _odometerController,
                                label: 'Odometer (miles)',
                                hint: 'Current reading',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _purchasePriceController,
                                label: 'Purchase Price',
                                hint: 'e.g. 35000',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _odometerController,
                                  label: 'Odometer (miles)',
                                  hint: 'Current reading',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _purchasePriceController,
                                  label: 'Purchase Price',
                                  hint: 'e.g. 35000',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Purchase date',
                          child: TextFormField(
                            controller: _purchaseDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Purchase Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Vehicle status',
                          child: DropdownButtonFormField<String>(
                            initialValue: _status,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'maintenance',
                                child: Text('Maintenance'),
                              ),
                              DropdownMenuItem(
                                value: 'retired',
                                child: Text('Retired'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _status = val);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Notes about this vehicle',
                          child: TextFormField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
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
                      label: 'Cancel and go back to vehicles',
                      child: OutlinedButton(
                        onPressed: () => context.go('/vehicles'),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      button: true,
                      label: widget.isEditing
                          ? 'Save changes to vehicle'
                          : 'Add new vehicle',
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
                                widget.isEditing
                                    ? 'Save Changes'
                                    : 'Add Vehicle',
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
    String? hint,
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
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (val) => val == null || val.isEmpty ? '$label is required' : null
            : null,
      ),
    );
  }
}
