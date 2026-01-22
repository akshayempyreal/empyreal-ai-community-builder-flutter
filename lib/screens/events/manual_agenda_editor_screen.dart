import 'dart:async';
import 'package:empyreal_ai_community_builder_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/agenda_item.dart';
import '../../models/session_models.dart';
import '../../blocs/agenda/agenda_bloc.dart';
import '../../repositories/event_repository.dart';
import '../../services/api_client.dart';
import '../../project_helpers.dart';

class ManualAgendaEditorScreen extends StatefulWidget {
  final Event event;
  final List<AgendaItem> existingAgenda;
  final Function(List<AgendaItem>) onSaveAgenda;
  final VoidCallback onBack;
  final User user;
  final String token;

  const ManualAgendaEditorScreen({
    super.key,
    required this.event,
    required this.existingAgenda,
    required this.onSaveAgenda,
    required this.onBack,
    required this.user,
    required this.token,
  });

  @override
  State<ManualAgendaEditorScreen> createState() => _ManualAgendaEditorScreenState();
}

class _ManualAgendaEditorScreenState extends State<ManualAgendaEditorScreen> {
  int _selectedDayIndex = 0;
  List<DaySession> _localSessions = [];

  void _initializeLocalSessions(SessionData data) {
    if (_localSessions.isEmpty) {
      setState(() {
        _localSessions = data.sessions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AgendaBloc(EventRepository(ApiClient())),
      child: BlocConsumer<AgendaBloc, AgendaState>(
        listener: (context, state) {
          if (state is AgendaSuccess) {
            _initializeLocalSessions(state.response.data!);
          } else if (state is AgendaFailure) {
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
              title: Text(_localSessions.isNotEmpty ? 'Edit Event Agenda' : 'Event Created Successfully'),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.gray900,
              elevation: 0,
            ),
            body: state is AgendaLoading
                ? const AgendaLoadingView()
                : _localSessions.isNotEmpty
                    ? _buildSessionsView()
                    : _buildInitialEventDetails(context),
            floatingActionButton: _localSessions.isNotEmpty
                ? FloatingActionButton.extended(
                    onPressed: () => _showSessionDialog(context, dayIndex: _selectedDayIndex),
                    label: const Text('Add Session'),
                    icon: const Icon(Icons.add),
                    backgroundColor: AppColors.primaryIndigo,
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildInitialEventDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Event Details',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Event Name', widget.event.name),
                  _buildDetailRow('Description', widget.event.description),
                  _buildDetailRow('Location', widget.event.location),
                  _buildDetailRow('Event Type', widget.event.type),
                  Row(
                    children: [
                      Expanded(child: _buildDetailRow('Start Date', _formatDate(widget.event.date))),
                      Expanded(child: _buildDetailRow('End Date', widget.event.endDate != null ? _formatDate(widget.event.endDate!) : 'N/A')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildDetailRow('Hours per Day', '${widget.event.duration} hours')),
                      Expanded(child: _buildDetailRow('Expected Audience', '${widget.event.audienceSize ?? 0}')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<AgendaBloc>().add(
                      GenerateSessionsRequested(eventId: widget.event.id, token: widget.token),
                    );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create Agenda'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsView() {
    final currentDay = _localSessions[_selectedDayIndex];

    return Column(
      children: [
        // Day selector
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _localSessions.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedDayIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryIndigo : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primaryIndigo : AppColors.gray300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : AppColors.gray500,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.gray900,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Session list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: currentDay.sessions.length,
            itemBuilder: (context, index) {
              final session = currentDay.sessions[index];
              return _buildSessionCard(session, index);
            },
          ),
        ),

        // Bottom Action
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSaveAndGoToDashboard,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: AppColors.primaryIndigo,
              ),
              child: const Text('Save & Go to Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(SessionItem session, int index) {
    final startTime = _formatTime(session.startDateTime);
    final endTime = _formatTime(session.endDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  startTime,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gray900),
                ),
                Text(
                  endTime,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getSessionColor(session.sessionType),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 100, // Approximate height
                color: _getSessionColor(session.sessionType).withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content card
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            session.sessionTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showSessionDialog(context, dayIndex: _selectedDayIndex, sessionIndex: index, session: session);
                            } else if (value == 'delete') {
                              _deleteSession(_selectedDayIndex, index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                          ],
                          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.gray400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.sessionDescription,
                      style: const TextStyle(color: AppColors.gray600, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getSessionColor(session.sessionType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: _getSessionColor(session.sessionType)),
                              const SizedBox(width: 4),
                              Text(
                                '${session.durationMinutes} min',
                                style: TextStyle(fontSize: 10, color: _getSessionColor(session.sessionType), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          session.sessionType.toUpperCase(),
                          style: TextStyle(fontSize: 10, color: AppColors.gray500, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSessionColor(String type) {
    switch (type.toLowerCase()) {
      case 'ceremony': return Colors.amber;
      case 'break': return Colors.teal;
      case 'activity': return AppColors.primaryPurple;
      case 'session':
      default: return AppColors.primaryIndigo;
    }
  }

  void _showSessionDialog(BuildContext context, {required int dayIndex, int? sessionIndex, SessionItem? session}) {
    final isEditing = sessionIndex != null;
    final titleController = TextEditingController(text: session?.sessionTitle ?? '');
    final descController = TextEditingController(text: session?.sessionDescription ?? '');
    final durationController = TextEditingController(text: session?.durationMinutes.toString() ?? '30');
    String selectedType = session?.sessionType ?? 'session';
    
    DateTime selectedStartTime;
    if (session != null) {
      selectedStartTime = DateTime.parse(session.startDateTime).toLocal();
    } else {
      // For new sessions, default to the start of the day or after the last session
      if (_localSessions[dayIndex].sessions.isNotEmpty) {
        selectedStartTime = DateTime.parse(_localSessions[dayIndex].sessions.last.endDateTime).toLocal();
      } else {
        selectedStartTime = DateTime.parse(_localSessions[dayIndex].dayStartDateTime).toLocal();
      }
    }

    String? clashError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Session' : 'Add New Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (clashError != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            clashError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title *'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'session', child: Text('Regular Session')),
                    DropdownMenuItem(value: 'ceremony', child: Text('Ceremony')),
                    DropdownMenuItem(value: 'activity', child: Text('Activity')),
                    DropdownMenuItem(value: 'break', child: Text('Break')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedType = val!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(DateFormat('hh:mm a').format(selectedStartTime)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedStartTime),
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedStartTime = DateTime(
                          selectedStartTime.year,
                          selectedStartTime.month,
                          selectedStartTime.day,
                          time.hour,
                          time.minute,
                        );
                        clashError = null; // Clear error when time changes
                      });
                    }
                  },
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration (minutes) *'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setDialogState(() => clashError = null),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) return;
                
                final duration = int.tryParse(durationController.text) ?? 30;
                final newStart = selectedStartTime;
                final newEnd = selectedStartTime.add(Duration(minutes: duration));

                // Validation: Check for time clashes
                String? error;
                final daySessions = _localSessions[dayIndex].sessions;
                
                // Compare everything in Local time to avoid timezone jumps
                final newStartLocal = newStart.toLocal();
                final newEndLocal = newEnd.toLocal();

                for (int i = 0; i < daySessions.length; i++) {
                  if (isEditing && i == sessionIndex) continue;
                  
                  final otherStartLocal = DateTime.parse(daySessions[i].startDateTime).toLocal();
                  final otherEndLocal = DateTime.parse(daySessions[i].endDateTime).toLocal();
                  
                  // Overlap condition: (StartA < EndB) and (EndA > StartB)
                  // Use 1-minute buffer to allow back-to-back sessions (StartA == EndB is fine)
                  if (newStartLocal.isBefore(otherEndLocal) && newEndLocal.isAfter(otherStartLocal)) {
                    final otherStartTimeStr = DateFormat('hh:mm a').format(otherStartLocal);
                    final otherEndTimeStr = DateFormat('hh:mm a').format(otherEndLocal);
                    error = 'Clashes with "${daySessions[i].sessionTitle}" ($otherStartTimeStr - $otherEndTimeStr)';
                    break;
                  }
                }

                if (error != null) {
                  setDialogState(() {
                    clashError = error;
                  });
                  return;
                }

                // Important: Always save back in UTC to keep consistent with what API provides/expects
                final newSession = SessionItem(
                  sessionTitle: titleController.text,
                  sessionDescription: descController.text,
                  startDateTime: newStart.toUtc().toIso8601String(),
                  endDateTime: newEnd.toUtc().toIso8601String(),
                  durationMinutes: duration,
                  sessionType: selectedType,
                );

                setState(() {
                  final updatedDaySessions = List<SessionItem>.from(_localSessions[dayIndex].sessions);
                  if (isEditing) {
                    updatedDaySessions[sessionIndex] = newSession;
                  } else {
                    updatedDaySessions.add(newSession);
                  }
                  
                  // Sort sessions by actual DateTime value, not string comparison
                  updatedDaySessions.sort((a, b) {
                    final aTime = DateTime.parse(a.startDateTime);
                    final bTime = DateTime.parse(b.startDateTime);
                    return aTime.compareTo(bTime);
                  });
                  
                  _localSessions[dayIndex] = _localSessions[dayIndex].copyWith(sessions: updatedDaySessions);
                });
                
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),

          ],
        ),
      ),
    );


  }

  void _deleteSession(int dayIndex, int sessionIndex) {
    setState(() {
      final daySessions = List<SessionItem>.from(_localSessions[dayIndex].sessions);
      daySessions.removeAt(sessionIndex);
      _localSessions[dayIndex] = _localSessions[dayIndex].copyWith(sessions: daySessions);
    });
  }

  void _handleSaveAndGoToDashboard() {
    final List<AgendaItem> items = [];
    int counter = 1;
    
    for (var day in _localSessions) {
      for (var session in day.sessions) {
        final start = DateTime.parse(session.startDateTime).toLocal();
        final end = DateTime.parse(session.endDateTime).toLocal();
        
        items.add(AgendaItem(
          id: 'gen_$counter',
          title: session.sessionTitle,
          startTime: DateFormat('HH:mm').format(start),
          endTime: DateFormat('HH:mm').format(end),
          type: session.sessionType,
          description: session.sessionDescription,
        ));
        counter++;
      }
    }
    
    widget.onSaveAgenda(items);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.gray500, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: AppColors.gray900, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }
}

class AgendaLoadingView extends StatefulWidget {
  const AgendaLoadingView({super.key});

  @override
  State<AgendaLoadingView> createState() => _AgendaLoadingViewState();
}

class _AgendaLoadingViewState extends State<AgendaLoadingView> with SingleTickerProviderStateMixin {
  int _messageIndex = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final List<String> _messages = [
    'Creating Agenda...',
    'Managing Timing...',
    'Arranging Sessions...',
    'Adding Breaks...',
    'Optimizing Schedule...',
    'Finalizing Details...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium AI Orb Animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Rings
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryIndigo.withOpacity(0.05),
                  ),
                ),
              ),
              ScaleTransition(
                scale: Tween<double>(begin: 1.2, end: 0.8).animate(_pulseController),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryIndigo.withOpacity(0.1), width: 1),
                  ),
                ),
              ),
              // Main Orb
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryIndigo.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                ),
              ),
              // Rotating Progress Ring
              const SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryIndigo),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 64),
          
          // Status Text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey<int>(_messageIndex),
              children: [
                Text(
                  _messages[_messageIndex],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getSubtitle(_messageIndex),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Technical Progress bar
          Container(
            width: 240,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryIndigo),
                minHeight: 6,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 14, color: AppColors.gray400),
              SizedBox(width: 8),
              Text(
                'Architecting via Empyre AI Engine',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray400,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSubtitle(int index) {
    switch (index) {
      case 0: return 'Structuring the foundation of your event';
      case 1: return 'Ensuring a perfect flow for every speaker';
      case 2: return 'Balancing learning and interactive workshops';
      case 3: return 'Strategically placing networking intervals';
      case 4: return 'Maximizing engagement across all segments';
      case 5: return 'Polishing the timeline for your community';
      default: return 'Architecting your perfect community event';
    }
  }
}

