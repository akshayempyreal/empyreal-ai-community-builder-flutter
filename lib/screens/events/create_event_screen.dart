import 'package:empyreal_ai_community_builder_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/event_api_models.dart';
import '../../blocs/create_event/create_event_bloc.dart';
import '../../blocs/create_event/create_event_event.dart';
import '../../blocs/create_event/create_event_state.dart';
import '../../repositories/event_repository.dart';
import '../../services/api_client.dart';

class CreateEventScreen extends StatefulWidget {
  final Function(Event) onCreateEvent;
  final VoidCallback onBack;
  final User user;
  final String token;

  const CreateEventScreen({
    super.key,
    required this.onCreateEvent,
    required this.onBack,
    required this.user,
    required this.token,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = '';
  DateTime? _startDate;
  DateTime? _endDate;
  final _durationController = TextEditingController();
  final _audienceSizeController = TextEditingController();
  final String _planningMode = 'automated';
  
  // State for location selection
  List<Map<String, dynamic>> _allLocations = [];
  double? _selectedLat;
  double? _selectedLng;
  final List<String> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final String response = await rootBundle.loadString('assets/locations.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _allLocations = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.read<CreateEventBloc>().add(
        CreateEventFileUploading(file: image, token: widget.token),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _audienceSizeController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final request = CreateEventRequest(
        name: _nameController.text,
        startDate: _startDate!.toUtc().toIso8601String(),
        endDate: _endDate?.toUtc().toIso8601String() ?? _startDate!.toUtc().toIso8601String(),
        description: _descriptionController.text,
        attachments: _attachments,
        hoursInDay: int.parse(_durationController.text),
        eventType: _selectedType,
        otherEventType: _selectedType == 'other' ? 'library type event' : null,
        expectedAudienceSize: int.parse(_audienceSizeController.text),
        location: _locationController.text,
        lat: _selectedLat?.toString() ?? "0.0",
        long: _selectedLng?.toString() ?? "0.0",
      );

      context.read<CreateEventBloc>().add(
        CreateEventSubmitted(request: request, token: widget.token),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateEventBloc(EventRepository(ApiClient())),
      child: BlocConsumer<CreateEventBloc, CreateEventState>(
        listener: (context, state) {
          if (state is CreateEventSuccess) {
            final data = state.response.data!;
            final event = Event(
              id: data.id,
              name: data.name,
              description: data.description,
              location: data.location,
              type: data.eventType,
              date: data.startDate,
              endDate: data.endDate,
              duration: data.hoursInDay,
              audienceSize: data.expectedAudienceSize,
              planningMode: _planningMode,
              status: 'draft',
              createdAt: data.createdAt,
              createdBy: widget.user.id,
              attendeeCount: 0,
              latitude: data.coordinates?.coordinates[1],
              longitude: data.coordinates?.coordinates[0],
            );
            widget.onCreateEvent(event);
          } else if (state is CreateEventFileUploadSuccess) {
            setState(() {
              _attachments.add(state.fileUrl);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded successfully'), backgroundColor: Colors.green),
            );
          } else if (state is CreateEventFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.gray50,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              title: const Text('Create Event'),
            ),
            body: state is CreateEventLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Form(
                          key: _formKey,
                          child: _buildForm(context, state),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, CreateEventState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        final eventTypeField = DropdownButtonFormField<String>(
          isExpanded: true,
          value: _selectedType.isEmpty ? null : _selectedType,
          decoration: const InputDecoration(labelText: 'Event Type *'),
          items: const [
            DropdownMenuItem(value: 'community', child: Text('Community Event')),
            DropdownMenuItem(value: 'cultural', child: Text('Cultural Event')),
            DropdownMenuItem(value: 'workshop', child: Text('Workshop')),
            DropdownMenuItem(value: 'conference', child: Text('Conference')),
            DropdownMenuItem(value: 'seminar', child: Text('Seminar')),
            DropdownMenuItem(value: 'networking', child: Text('Networking Event')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) => setState(() => _selectedType = value ?? ''),
          validator: (value) => value == null ? 'Required' : null,
        );

        final audienceField = TextFormField(
          controller: _audienceSizeController,
          decoration: const InputDecoration(labelText: 'Expected Audience Size *', hintText: 'e.g., 200'),
          keyboardType: TextInputType.number,
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        );

        final startDateField = _buildDateField(
          label: 'Start Date & Time *',
          selectedDate: _startDate,
          onDateSelected: (date) => setState(() => _startDate = date),
        );

        final endDateField = _buildDateField(
          label: 'End Date & Time *',
          selectedDate: _endDate,
          onDateSelected: (date) => setState(() => _endDate = date),
          firstDate: _startDate,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create New Event', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Enter the basic details of your event', style: TextStyle(color: AppColors.gray600)),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Event Name *', hintText: 'e.g., Holi Event 2026'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.trim().split(RegExp(r'\s+')).length < 2) return 'At least 2 words required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description *', hintText: 'Describe your event...'),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.trim().split(RegExp(r'\s+')).length < 10) return 'At least 10 words required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildLocationAutocomplete(),
                const SizedBox(height: 16),
                
                if (isSmall) ...[
                  eventTypeField,
                  const SizedBox(height: 16),
                  audienceField,
                ] else
                  Row(children: [Expanded(child: eventTypeField), const SizedBox(width: 16), Expanded(child: audienceField)]),
                const SizedBox(height: 16),
                
                if (isSmall) ...[
                  startDateField,
                  const SizedBox(height: 16),
                  endDateField,
                ] else
                  Row(children: [Expanded(child: startDateField), const SizedBox(width: 16), Expanded(child: endDateField)]),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration per Day (hours) *',
                    helperText: 'How many hours will the event run each day?',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final num = int.tryParse(value ?? '');
                    if (num == null || num < 1 || num > 24) return 'Must be between 1 and 24';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                const Text('Attachments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildAttachmentsList(context, state),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: widget.onBack, child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: () => _handleSubmit(context), child: const Text('Create Event')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField({required String label, DateTime? selectedDate, required Function(DateTime) onDateSelected, DateTime? firstDate}) {
    return FormField<DateTime>(
      validator: (value) => selectedDate == null ? 'Required' : null,
      builder: (state) => InkWell(
        onTap: () async {
          // First show date picker
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? firstDate ?? DateTime.now(),
            firstDate: firstDate ?? DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          
          if (date != null && mounted) {
            // Store the selected date
            final selectedDateValue = date;
            
            // Wait for the date picker to fully close
            await Future.delayed(const Duration(milliseconds: 300));
            
            // Check if still mounted
            if (!mounted) return;
            
            // Show time picker immediately after date selection
            final time = await showTimePicker(
              context: context,
              initialTime: selectedDate != null
                  ? TimeOfDay.fromDateTime(selectedDate)
                  : const TimeOfDay(hour: 9, minute: 0),
              helpText: label.contains('Start') ? 'SELECT START TIME' : 'SELECT END TIME',
            );
            
            // Only proceed if time was selected and widget is still mounted
            if (time != null && mounted) {
              // Combine date and time into a single DateTime
              final dateTime = DateTime(
                selectedDateValue.year,
                selectedDateValue.month,
                selectedDateValue.day,
                time.hour,
                time.minute,
              );
              
              onDateSelected(dateTime);
              state.didChange(dateTime);
            }
            // Note: If user cancels time picker, nothing is saved (both date and time must be selected)
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: state.errorText,
            prefixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
          ),
          child: Text(
            selectedDate == null 
                ? 'Select date & time' 
                : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: selectedDate == null ? AppColors.gray400 : AppColors.gray900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationAutocomplete() {
    return Autocomplete<Map<String, dynamic>>(
      displayStringForOption: (option) => option['name'] as String,
      optionsBuilder: (textValue) => textValue.text.isEmpty 
          ? const Iterable<Map<String, dynamic>>.empty() 
          : _allLocations.where((loc) => loc['name'].toString().toLowerCase().contains(textValue.text.toLowerCase())),
      onSelected: (selection) => setState(() {
        _locationController.text = selection['name'];
        _selectedLat = selection['latitude'];
        _selectedLng = selection['longitude'];
      }),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) => TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: const InputDecoration(labelText: 'Location *', prefixIcon: Icon(Icons.location_on_outlined)),
        validator: (value) => (value == null || value.isEmpty || _selectedLat == null) ? 'Select a valid location' : null,
      ),
    );
  }

  Widget _buildAttachmentsList(BuildContext context, CreateEventState state) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._attachments.map((url) => Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.gray100,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: AppColors.gray200,
                      child: const Icon(Icons.broken_image_outlined, color: AppColors.gray400),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.gray200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => setState(() => _attachments.remove(url)),
                  ),
                ),
              ],
            ),
          )),
          if (state is CreateEventFileUploadLoading)
            Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: CircularProgressIndicator()),
            ),
          GestureDetector(
            onTap: () => _pickImage(context),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.indigo100.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryIndigo),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryIndigo),
                  Text('Add Photo', style: TextStyle(fontSize: 12, color: AppColors.primaryIndigo)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
