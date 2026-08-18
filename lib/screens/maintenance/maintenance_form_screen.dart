import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/maintenance_record.dart';
import '../../models/vehicle.dart';
import '../../services/auth_service.dart';
import '../../services/maintenance_service.dart';
import '../../services/vehicle_service.dart';
import '../../widgets/responsive_layout.dart';

class MaintenanceFormScreen extends StatefulWidget {
  final String? recordId;

  const MaintenanceFormScreen({super.key, this.recordId});

  bool get isEditing => recordId != null;

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maintenanceService = MaintenanceService();
  final _vehicleService = VehicleService();
  final _authService = AuthService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'general';
  String _status = 'completed';
  String? _selectedVehicleId;
  DateTime _serviceDate = DateTime.now();
  final _serviceDateController = TextEditingController();
  DateTime? _nextServiceDate;
  final _nextServiceDateController = TextEditingController();
  int? _nextServiceOdometer;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _companyId;
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _serviceDateController.text =
        '${_serviceDate.month.toString().padLeft(2, '0')}/${_serviceDate.day.toString().padLeft(2, '0')}/${_serviceDate.year}';
    _loadCompanyId();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    _serviceDateController.dispose();
    _nextServiceDateController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyId() async {
    final companyId = await _authService.getUserCompanyId();
    if (mounted) {
      setState(() => _companyId = companyId);
      _loadVehicles();
      if (widget.isEditing) _loadRecord();
    }
  }

  Future<void> _loadVehicles() async {
    if (_companyId == null) return;
    final stream = _vehicleService.getVehicles(_companyId!);
    stream.listen((vehicles) {
      if (mounted) setState(() => _vehicles = vehicles);
    });
  }

  Future<void> _loadRecord() async {
    if (_companyId == null) return;
    setState(() => _isLoading = true);

    final record =
        await _maintenanceService.getRecord(_companyId!, widget.recordId!);
    if (record != null && mounted) {
      _titleController.text = record.title;
      _descriptionController.text = record.description;
      _costController.text = record.cost.toString();
      _odometerController.text = record.odometerAtService.toString();
      _notesController.text = record.notes ?? '';
      _type = record.type;
      _status = record.status;
      _selectedVehicleId = record.vehicleId;
      _serviceDate = record.serviceDate;
      _serviceDateController.text =
          '${_serviceDate.month.toString().padLeft(2, '0')}/${_serviceDate.day.toString().padLeft(2, '0')}/${_serviceDate.year}';
      _nextServiceDate = record.nextServiceDate;
      if (_nextServiceDate != null) {
        _nextServiceDateController.text =
            '${_nextServiceDate!.month.toString().padLeft(2, '0')}/${_nextServiceDate!.day.toString().padLeft(2, '0')}/${_nextServiceDate!.year}';
      }
      _nextServiceOdometer = record.nextServiceOdometer;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _selectDate(BuildContext context, bool isServiceDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isServiceDate
          ? _serviceDate
          : _nextServiceDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() {
        if (isServiceDate) {
          _serviceDate = date;
          _serviceDateController.text =
              '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
        } else {
          _nextServiceDate = date;
          _nextServiceDateController.text =
              '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _companyId == null) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final record = MaintenanceRecord(
      id: widget.recordId ?? '',
      companyId: _companyId!,
      vehicleId: _selectedVehicleId!,
      type: _type,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      cost: double.tryParse(_costController.text.trim()) ?? 0,
      odometerAtService: int.tryParse(_odometerController.text.trim()) ?? 0,
      serviceDate: _serviceDate,
      nextServiceDate: _nextServiceDate,
      nextServiceOdometer: _nextServiceOdometer,
      status: _status,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      if (widget.isEditing) {
        await _maintenanceService.updateRecord(_companyId!, record);
      } else {
        await _maintenanceService.addRecord(_companyId!, record);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Record updated successfully'
                : 'Record added successfully'),
          ),
        );
        context.go('/maintenance');
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
                      onPressed: () => context.go('/maintenance'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          widget.isEditing
                              ? 'Edit Maintenance Record'
                              : 'Add Maintenance Record',
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
                            'Service Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Select vehicle for maintenance',
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedVehicleId,
                            decoration: const InputDecoration(
                              labelText: 'Vehicle *',
                              border: OutlineInputBorder(),
                            ),
                            items: _vehicles
                                .map((v) => DropdownMenuItem(
                                      value: v.id,
                                      child: Text(v.displayName),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedVehicleId = val),
                            validator: (val) =>
                                val == null ? 'Select a vehicle' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Type of maintenance',
                          child: DropdownButtonFormField<String>(
                            initialValue: _type,
                            decoration: const InputDecoration(
                              labelText: 'Type *',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'general', child: Text('General')),
                              DropdownMenuItem(
                                  value: 'oil_change', child: Text('Oil Change')),
                              DropdownMenuItem(
                                  value: 'tire', child: Text('Tire Service')),
                              DropdownMenuItem(
                                  value: 'brake', child: Text('Brake Service')),
                              DropdownMenuItem(
                                  value: 'inspection', child: Text('Inspection')),
                              DropdownMenuItem(
                                  value: 'repair', child: Text('Repair')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _type = val);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _titleController,
                          label: 'Title *',
                          hint: 'e.g. 50,000 Mile Service',
                          required: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          maxLines: 3,
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
                            'Cost & Odometer',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ResponsiveLayout(
                          mobile: Column(
                            children: [
                              _buildTextField(
                                controller: _costController,
                                label: 'Cost',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _odometerController,
                                label: 'Odometer at Service',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          desktop: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _costController,
                                  label: 'Cost',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _odometerController,
                                  label: 'Odometer at Service',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Service date',
                          child: TextFormField(
                            controller: _serviceDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Service Date *',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => _selectDate(context, true),
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
                            'Schedule Next Service',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Maintenance status',
                          child: DropdownButtonFormField<String>(
                            initialValue: _status,
                            decoration: const InputDecoration(
                              labelText: 'Status *',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'completed', child: Text('Completed')),
                              DropdownMenuItem(
                                  value: 'scheduled', child: Text('Scheduled')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _status = val);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Next service date',
                          child: TextFormField(
                            controller: _nextServiceDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Next Service Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
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
                        onPressed: () => context.go('/maintenance'),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Semantics(
                      button: true,
                      label: widget.isEditing
                          ? 'Save changes'
                          : 'Add maintenance record',
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
                                    : 'Add Record',
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
          alignLabelWithHint: maxLines > 1,
        ),
        validator: required
            ? (val) => val == null || val.isEmpty ? '$label is required' : null
            : null,
      ),
    );
  }
}
