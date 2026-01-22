import 'package:empyreal_ai_community_builder_flutter/models/agenda_item.dart';
import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:empyreal_ai_community_builder_flutter/models/user.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../repositories/event_repository.dart';
import '../../../services/api_client.dart';

class AIAgendaBuilderScreen extends StatefulWidget {
  final Event event;
  final Function(List<AgendaItem>) onSaveAgenda;
  final VoidCallback onBack;
  final User user;
  final String token;
  final VoidCallback onSaveAndRedirect;
  final Function(String) onNavigateToGeneratedAgenda;

  const AIAgendaBuilderScreen({
    super.key,
    required this.event,
    required this.onSaveAgenda,
    required this.onBack,
    required this.user,
    required this.token,
    required this.onSaveAndRedirect,
    required this.onNavigateToGeneratedAgenda,
  });

  @override
  State<AIAgendaBuilderScreen> createState() => _AIAgendaBuilderScreenState();
}

class _AIAgendaBuilderScreenState extends State<AIAgendaBuilderScreen>
    with SingleTickerProviderStateMixin {
  bool _isGenerating = false;
  String? _errorMessage;
  String? _generatedAgenda;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  static const double _progressValue = 0.65; // existing progress logic

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _progressAnimation =
        Tween<double>(begin: 0, end: _progressValue).animate(
          CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
        );

    _generateAgenda();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _generateAgenda() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    _progressController.forward();

    try {
      final repository = EventRepository(ApiClient());
      final response =
      await repository.generateAgenda(widget.event.id, widget.token);

      if (response.status && response.data != null) {
        setState(() {
          _generatedAgenda = response.data!.agenda;
          _isGenerating = false;
        });

        if (mounted) {
          widget.onNavigateToGeneratedAgenda(_generatedAgenda!);
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme),
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildAICircle(),
              const SizedBox(height: 32),

              Text(
                _isGenerating
                    ? 'Generating your agenda...'
                    : 'Agenda generated!',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                _isGenerating
                    ? 'AI is analyzing your event details'
                    : 'Please wait...',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.info),
              ),

              const SizedBox(height: 32),
              _buildAnimatedProgressBar(theme),
              const SizedBox(height: 32),

              if (_isGenerating) _buildSuggestionCard(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: widget.onBack,
      ),
      title: const Text(
        'AI Generating Agenda',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAnimatedProgressBar(ThemeData theme) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (_, __) {
        final progressValue = _progressAnimation.value;
        final isComplete = progressValue >= 1.0;
        final borderColor = isComplete ? AppColors.success : AppColors.gray300;
        final progressColor = isComplete ? AppColors.success : AppColors.info;
        
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Completion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(progressValue * 100).round()}%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                color: theme.scaffoldBackgroundColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    // Background
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.gray100.withOpacity(0.3),
                    ),
                    // Progress fill with smooth animation
                    FractionallySizedBox(
                      widthFactor: progressValue,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: isComplete
                                ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                                : [progressColor, progressColor.withOpacity(0.8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAICircle() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.info, AppColors.indigo100],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.info,
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'AI is preparing your agenda...',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Optimizing sessions, time slots, and engagement flow.',
            style: TextStyle(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to Generate Agenda',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateAgenda,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
