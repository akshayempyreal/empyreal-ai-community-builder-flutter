import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../theme/app_theme.dart';

class CreateEventScreen extends StatefulWidget {
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
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  
  // Form fields
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = '';
  DateTime? _startDate;
  DateTime? _endDate;
  final _durationController = TextEditingController();
  final _audienceSizeController = TextEditingController();
  String _planningMode = 'automated';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _audienceSizeController.dispose();
    super.dispose();
  }

  bool get _canProceedToStep2 {
    return _nameController.text.isNotEmpty &&
        _selectedType.isNotEmpty &&
        _startDate != null &&
        _durationController.text.isNotEmpty;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        type: _selectedType,
        date: _startDate!.toIso8601String().split('T')[0],
        endDate: _endDate?.toIso8601String().split('T')[0],
        duration: int.parse(_durationController.text),
        audienceSize: _audienceSizeController.text.isNotEmpty 
            ? int.parse(_audienceSizeController.text) 
            : null,
        planningMode: _planningMode,
        status: 'draft',
        createdAt: DateTime.now().toIso8601String(),
        attendeeCount: 0,
      );
      widget.onCreateEvent(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
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
              backgroundColor: AppTheme.indigo100,
              child: Text(
                widget.user.name[0].toUpperCase(),
                style: const TextStyle(color: AppTheme.primaryIndigo),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Progress indicator
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 600;
                    final connectorWidth = isSmall ? 20.0 : 60.0;
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepIndicator(0, 'Event Details'),
                          Container(
                            width: connectorWidth,
                            height: 2,
                            color: _currentStep >= 1 ? AppTheme.primaryIndigo : AppTheme.gray300,
                          ),
                          _buildStepIndicator(1, 'Planning Mode'),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                // Form
                Form(
                  key: _formKey,
                  child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryIndigo : AppTheme.gray300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : AppTheme.gray600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.gray900 : AppTheme.gray500,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        final eventTypeField = DropdownButtonFormField<String>(
          isExpanded: true,
          value: _selectedType.isEmpty ? null : _selectedType,
          decoration: const InputDecoration(
            labelText: 'Event Type *',
          ),
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
          decoration: const InputDecoration(
            labelText: 'Expected Audience Size *',
            hintText: 'e.g., 200',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        );

        final startDateField = FormField<DateTime>(
          initialValue: _startDate,
          validator: (value) => value == null ? 'Required' : null,
          builder: (FormFieldState<DateTime> state) {
            return InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                  state.didChange(date);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Start Date *',
                  errorText: state.errorText,
                ),
                child: Text(
                  _startDate == null 
                      ? 'Select date' 
                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                ),
              ),
            );
          },
        );

        final endDateField = FormField<DateTime>(
          initialValue: _endDate,
          validator: (value) => value == null ? 'Required' : null,
          builder: (FormFieldState<DateTime> state) {
            return InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                  state.didChange(date);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'End Date *',
                  errorText: state.errorText,
                ),
                child: Text(
                  _endDate == null 
                      ? 'Select date' 
                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                ),
              ),
            );
          },
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Event',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the basic details of your event',
                  style: TextStyle(color: AppTheme.gray600),
                ),
                const SizedBox(height: 24),
                
                // Event Name
                TextFormField(
                  controller: _nameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Event Name *',
                    hintText: 'e.g., Holi Community Event 2026',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final words = value.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
                    if (words < 2) {
                      return 'Name must have at least 2 words (Current: $words)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe your event (min 10 words)...',
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final words = value.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
                    if (words < 10) {
                      return 'Description must have at least 10 words (Current: $words)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Location
                TextFormField(
                  controller: _locationController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    hintText: 'e.g., Central Park, New York',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
                // Type and Audience Size
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
                const SizedBox(height: 16),
                
                // Dates
                if (isSmall) ...[
                  startDateField,
                  const SizedBox(height: 16),
                  endDateField,
                ] else
                  Row(
                    children: [
                      Expanded(child: startDateField),
                      const SizedBox(width: 16),
                      Expanded(child: endDateField),
                    ],
                  ),
                const SizedBox(height: 16),
                
                // Duration
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration per Day (hours) *',
                    hintText: 'e.g., 7',
                    helperText: 'How many hours will the event run each day?',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final num = int.tryParse(value!);
                    if (num == null || num < 1 || num > 24) {
                      return 'Must be between 1 and 24';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: widget.onBack,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _currentStep = 1);
                        }
                      },
                      child: const Text('Next Step'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep2() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Planning Mode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'How would you like to plan your event agenda?',
              style: TextStyle(color: AppTheme.gray600),
            ),
            const SizedBox(height: 24),
            
            // Automated option
            _buildPlanningModeCard(
              value: 'automated',
              title: 'Fully Automated AI Planning',
              subtitle: 'Recommended for quick setup',
              icon: Icons.auto_awesome,
              iconColor: AppTheme.primaryIndigo,
              iconBg: AppTheme.indigo100,
              description: 'Let AI generate the complete event agenda including sessions, activities, and breaks based on your event type and duration.',
              features: [
                'AI generates all sessions and timings',
                'Smart break placement',
                'Context-aware activity suggestions',
                'Editable after generation',
              ],
            ),
            const SizedBox(height: 16),
            
            // Manual option
            _buildPlanningModeCard(
              value: 'manual',
              title: 'Manual / Hybrid Planning',
              subtitle: 'For custom agendas',
              icon: Icons.edit,
              iconColor: AppTheme.primaryPurple,
              iconBg: const Color(0xFFF3E8FF),
              description: 'Create your own agenda with specific sessions and time slots. AI will assist with suggestions and validation.',
              features: [
                'Full control over sessions',
                'Fix specific time slots',
                'AI suggests improvements',
                'Conflict detection',
              ],
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  child: const Text('Back'),
                ),
                ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Create Event'),
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
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String description,
    required List<String> features,
  }) {
    final isSelected = _planningMode == value;
    return InkWell(
      onTap: () => setState(() => _planningMode = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryIndigo : AppTheme.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.indigo100.withOpacity(0.3) : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              groupValue: _planningMode,
              onChanged: (val) => setState(() => _planningMode = val!),
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
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: AppTheme.gray700),
                  ),
                  const SizedBox(height: 12),
                  ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
