import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:convert';
import '../../../core/animation/app_animations.dart';
import '../../../models/user.dart';
import '../../../models/event.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/validators/form_validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../blocs/events/create_event_bloc.dart';
import '../../../blocs/events/create_event_event.dart';
import '../../../blocs/events/create_event_state.dart';
import '../../../core/animation/app_animations.dart';

class CreateEventScreen extends StatelessWidget {
  final Function(Event) onCreateEvent;
  final VoidCallback onBack;
  final User user;

  const CreateEventScreen({
    super.key,
    required this.onCreateEvent,
    required this.onBack,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateEventBloc(),
      child: _CreateEventView(
        onCreateEvent: onCreateEvent,
        onBack: onBack,
        user: user,
      ),
    );
  }
}

class _CreateEventView extends StatefulWidget {
  final Function(Event) onCreateEvent;
  final VoidCallback onBack;
  final User user;

  const _CreateEventView({
    required this.onCreateEvent,
    required this.onBack,
    required this.user,
  });

  @override
  State<_CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<_CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers still needed for text field interaction
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _audienceSizeController = TextEditingController();
  
  // Time pickers - removed local state in favor of BLoC state

  List<Map<String, dynamic>> _allLocations = [];

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

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _audienceSizeController.dispose();
    super.dispose();
  }

  void _syncDetails(CreateEventState state) {
    context.read<CreateEventBloc>().add(UpdateEventDetails({
      'name': _nameController.text,
      'location': _locationController.text,
      'description': _descriptionController.text,
      'duration': _durationController.text,
      'audienceSize': _audienceSizeController.text,
      'type': state.type,
      'startDate': state.startDate,
      'endDate': state.endDate,
      'startTime': state.startTime,
      'endTime': state.endTime,
      'planningMode': state.planningMode,
      'latitude': state.latitude,
      'longitude': state.longitude,
    }));
  }

  void _handleSubmit(CreateEventState state) {
    if (_formKey.currentState!.validate()) {
        // Combine date and time into full DateTime objects
        final startDateTime = DateTime(
          state.startDate!.year,
          state.startDate!.month,
          state.startDate!.day,
          state.startTime?.hour ?? 0,
          state.startTime?.minute ?? 0,
        );
        final endDateTime = DateTime(
          state.endDate!.year,
          state.endDate!.month,
          state.endDate!.day,
          state.endTime?.hour ?? 0,
          state.endTime?.minute ?? 0,
        );
        
        // Validate chronological order
        if (!endDateTime.isAfter(startDateTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End date/time must be after start date/time'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final event = Event(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          type: state.type,
          date: startDateTime.toIso8601String(),
          endDate: endDateTime.toIso8601String(),
          duration: int.parse(_durationController.text),
          audienceSize: _audienceSizeController.text.isNotEmpty 
              ? int.parse(_audienceSizeController.text) 
              : null,
          planningMode: state.planningMode,
          status: 'draft',
          createdAt: DateTime.now().toIso8601String(),
          createdBy: widget.user.id,
          attendeeCount: 0,
          latitude: state.latitude,
          longitude: state.longitude,
        );
      widget.onCreateEvent(event);
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateEventBloc, CreateEventState>(
      listener: (context, state) {
        if (state.status == CreateEventStatus.success) {
          // Success handled in _handleSubmit for now as requested by user's logic
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            ),
            title: const Text('Create Event'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: AppColors.indigo100,
                  child: Text(
                    widget.user.name[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primaryIndigo),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      _buildProgressIndicator(state.currentStep),
                      const SizedBox(height: 32),
                      AnimatedSwitcher(
                        duration: AppAnimations.normal,
                        transitionBuilder: AppAnimations.pageTransitionBuilder,
                        child: Form(
                          key: ValueKey('step_${state.currentStep}'),
                          child: state.currentStep == 0 ? _buildStep1(state) : _buildStep2(state),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;
        final connectorWidth = isSmall ? 20.0 : 60.0;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepIndicator(0, 'Event Details', currentStep),
            Container(
              width: connectorWidth,
              height: 2,
              color: currentStep >= 1 ? AppColors.primaryIndigo : AppColors.gray300,
            ),
            _buildStepIndicator(1, 'Planning Mode', currentStep),
          ],
        );
      },
    );
  }

  Widget _buildStepIndicator(int step, String label, int currentStep) {
    final isActive = currentStep >= step;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryIndigo : AppColors.gray300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.gray600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.gray900 : AppColors.gray500,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(CreateEventState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        final eventTypeField = DropdownButtonFormField<String>(
          isExpanded: true,
          value: state.type.isEmpty ? null : state.type,
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
          onChanged: (value) {
            context.read<CreateEventBloc>().add(UpdateEventDetails({'type': value ?? ''}));
          },
          validator: (value) => FormValidators.required(value, fieldName: 'Event Type'),
        );

        final audienceField = TextFormField(
          controller: _audienceSizeController,
          decoration: const InputDecoration(
            labelText: 'Expected Audience Size *',
            hintText: 'e.g., 200',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => FormValidators.required(value, fieldName: 'Audience size'),
        );

        final startDateField = _buildDatePicker(
          label: 'Start Date & Time *',
          selectedDate: state.startDate != null && state.startTime != null
              ? DateTime(
                  state.startDate!.year,
                  state.startDate!.month,
                  state.startDate!.day,
                  state.startTime!.hour,
                  state.startTime!.minute,
                )
              : state.startDate,
          onDateSelected: (dateTime) {
            // Extract date and time from the combined DateTime
            final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
            final time = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
            context.read<CreateEventBloc>().add(UpdateEventDetails({
              'startDate': date,
              'startTime': time,
            }));
          },
        );

        final endDateField = _buildDatePicker(
          label: 'End Date & Time *',
          selectedDate: state.endDate != null && state.endTime != null
              ? DateTime(
                  state.endDate!.year,
                  state.endDate!.month,
                  state.endDate!.day,
                  state.endTime!.hour,
                  state.endTime!.minute,
                )
              : state.endDate,
          firstDate: state.startDate,
          onDateSelected: (dateTime) {
            // Extract date and time from the combined DateTime
            final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
            final time = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
            context.read<CreateEventBloc>().add(UpdateEventDetails({
              'endDate': date,
              'endTime': time,
            }));
          },
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create New Event', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text('Enter the basic details of your event', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name *',
                    hintText: 'e.g., Holi Community Event 2026',
                  ),
                  validator: (value) => FormValidators.wordCount(value, 2, fieldName: 'Name'),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe your event (min 10 words)...',
                  ),
                  maxLines: 4,
                  validator: (value) => FormValidators.wordCount(value, 10, fieldName: 'Description'),
                ),
                const SizedBox(height: 16),
                
                _buildLocationAutocomplete(state),
                const SizedBox(height: 24),
                
                if (isSmall) ...[
                  eventTypeField,
                  const SizedBox(height: 16),
                  audienceField,
                ] else
                  Row(
                    children: [
                      Expanded(child: eventTypeField),
                      const SizedBox(width: 16),
                      Expanded(child: audienceField),
                    ],
                  ),
                const SizedBox(height: 24),

                // Start Date & Time
                Text('Start Schedule', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                startDateField,
                const SizedBox(height: 16),

                // End Date & Time
                Text('End Schedule', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                endDateField,
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration per Day (hours) *',
                    hintText: 'e.g., 7',
                    helperText: 'How many hours will the event run each day?',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => FormValidators.numberRange(value, 1, 24, fieldName: 'Duration'),
                ),
                const SizedBox(height: 32),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 300;
                    return Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SecondaryButton(
                          text: 'Cancel',
                          onPressed: widget.onBack,
                          width: isSmall ? constraints.maxWidth : 120,
                        ),
                        PrimaryButton(
                          text: 'Next Step',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<CreateEventBloc>().add(const ChangeStep(1));
                            }
                          },
                          width: isSmall ? constraints.maxWidth : 140,
                        ),
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    DateTime? firstDate,
    VoidCallback? onPostSelect,
  }) {
    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: (value) => value == null ? 'Required' : null,
      builder: (state) {
        return InkWell(
          onTap: () async {
            // First show date picker
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? firstDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            
            if (date != null && mounted) {
              // Store the selected date and context
              final selectedDateValue = date;
              final currentContext = context;
              
              // Use SchedulerBinding to ensure date picker is fully dismissed
              SchedulerBinding.instance.addPostFrameCallback((_) {
                // Use Timer to delay showing time picker
                Timer(const Duration(milliseconds: 300), () {
                  if (!mounted) return;
                  
                  // Show time picker
                  showTimePicker(
                    context: currentContext,
                    initialTime: selectedDate != null && selectedDate!.hour > 0
                        ? TimeOfDay.fromDateTime(selectedDate!)
                        : const TimeOfDay(hour: 9, minute: 0),
                    helpText: label.contains('Start') ? 'SELECT START TIME' : 'SELECT END TIME',
                  ).then((time) {
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
                      
                      // Update the form state
                      onDateSelected(dateTime);
                      state.didChange(dateTime);
                      
                      // Trigger any post-selection callback if provided
                      if (onPostSelect != null) {
                        onPostSelect();
                      }
                    }
                    // Note: If user cancels time picker, nothing is saved (both date and time must be selected)
                  });
                });
              });
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
        );
      },
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? selectedTime,
    required Function(TimeOfDay) onTimeSelected,
    bool enabled = true,
  }) {
    return FormField<TimeOfDay>(
      initialValue: selectedTime,
      validator: (value) => value == null ? 'Required' : null,
      builder: (state) {
        return InkWell(
          onTap: enabled ? () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
            );
            if (time != null) {
              onTimeSelected(time);
              state.didChange(time);
            }
          } : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: state.errorText,
              prefixIcon: Icon(
                Icons.access_time_outlined, 
                size: 20, 
                color: enabled ? AppColors.primaryIndigo : AppColors.gray400,
              ),
              filled: !enabled,
              fillColor: enabled ? null : AppColors.gray100,
            ),
            child: Text(
              selectedTime == null
                  ? 'Select time'
                  : selectedTime.format(context),
              style: TextStyle(
                color: enabled 
                    ? (selectedTime == null ? AppColors.gray400 : AppColors.gray900)
                    : AppColors.gray500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationAutocomplete(CreateEventState state) {
    return Autocomplete<Map<String, dynamic>>(
      displayStringForOption: (option) => option['name'] as String,
      initialValue: TextEditingValue(text: _locationController.text),
      optionsBuilder: (textValue) {
        if (textValue.text.isEmpty) return const Iterable.empty();
        return _allLocations.where((loc) => 
          loc['name'].toString().toLowerCase().contains(textValue.text.toLowerCase()));
      },
      onSelected: (selection) {
        _locationController.text = selection['name'];
        context.read<CreateEventBloc>().add(UpdateEventDetails({
          'location': selection['name'],
          'latitude': selection['latitude'],
          'longitude': selection['longitude'],
        }));
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Location *',
            hintText: 'Search city, park or venue...',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          onChanged: (value) {
            _locationController.text = value;
            context.read<CreateEventBloc>().add(const UpdateEventDetails({
              'latitude': null,
              'longitude': null,
            }));
          },
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (state.latitude == null) return 'Please select from list';
            return null;
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: MediaQuery.of(context).size.width > 800 ? 752 : MediaQuery.of(context).size.width - 48,
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: AppColors.gray400),
                    title: Text(option['name']),
                    subtitle: Text('Lat: ${option['latitude']}, Lng: ${option['longitude']}', style: const TextStyle(fontSize: 10)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep2(CreateEventState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Planning Mode', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text('How would you like to plan your event agenda?', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            
            _buildPlanningModeCard(
              value: 'automated',
              currentState: state,
              title: 'Fully Automated AI Planning',
              subtitle: 'Recommended for quick setup',
              icon: Icons.auto_awesome,
              iconColor: AppColors.primaryIndigo,
              iconBg: AppColors.indigo100,
              description: 'Let AI generate the complete event agenda sessions based on your details.',
              features: ['AI generated sessions', 'Smart timing', 'Context aware'],
            ),
            const SizedBox(height: 16),
            _buildPlanningModeCard(
              value: 'manual',
              currentState: state,
              title: 'Manual / Hybrid Planning',
              subtitle: 'For custom agendas',
              icon: Icons.edit,
              iconColor: AppColors.primaryPurple,
              iconBg: const Color(0xFFF3E8FF),
              description: 'Create your own agenda. AI will assist with suggestions.',
              features: ['Full control', 'AI suggestions', 'Conflict detection'],
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SecondaryButton(
                  text: 'Back', 
                  onPressed: () => context.read<CreateEventBloc>().add(const ChangeStep(0)),
                  width: 100,
                ),
                PrimaryButton(
                  text: 'Create Event',
                  isLoading: state.status == CreateEventStatus.loading,
                  onPressed: () => _handleSubmit(state),
                  width: 180,
                  icon: Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningModeCard({
    required String value,
    required CreateEventState currentState,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String description,
    required List<String> features,
  }) {
    final isSelected = currentState.planningMode == value;
    return InkWell(
      onTap: () => context.read<CreateEventBloc>().add(UpdateEventDetails({'planningMode': value})),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryIndigo : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primaryIndigo.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              groupValue: currentState.planningMode,
              onChanged: (val) => context.read<CreateEventBloc>().add(UpdateEventDetails({'planningMode': val!})),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(description, style: const TextStyle(fontSize: 14, color: AppColors.gray700)),
                  const SizedBox(height: 12),
                  ...features.map((feature) => _buildFeatureItem(feature, iconColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: color),
          const SizedBox(width: 8),
          Text(feature, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
        ],
      ),
    );
  }
}
