import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/agenda_item.dart';
import '../../theme/app_theme.dart';

class AIAgendaBuilderScreen extends StatelessWidget {
  final Event event;
  final Function(List<AgendaItem>) onSaveAgenda;
  final VoidCallback onBack;
  final User user;

  const AIAgendaBuilderScreen({
    super.key,
    required this.event,
    required this.onSaveAgenda,
    required this.onBack,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: onBack,
        ),
        title: const Text(
          'AI Generating Agenda',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.blue,
            height: 2,
            width: 120, // Approximate width for the indicator
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? _buildBottomNav()
          : null,
      body: SafeArea(
        child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // AI Circle Indicator
                            _buildAICircle(),
                            const SizedBox(height: 32),

                            // Status Text
                            const Text(
                              'Optimizing break placement...',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Analyzing event flow',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.blue600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Progress Section
                            _buildProgressSection(),
                            const SizedBox(height: 32),

                            // Live Suggestions Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Live AI Suggestions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.indigo100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '4 NEW',
                                    style: TextStyle(
                                      color: AppTheme.primaryIndigo,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Suggestion Card
                            _buildSuggestionCard(),

                            const SizedBox(height: 16),

                            // Swipe hint
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.swipe_left, color: AppTheme.gray400),
                                    SizedBox(height: 4),
                                    Text('SWIPE LEFT TO SKIP', style: TextStyle(fontSize: 10, color: AppTheme.gray400)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(Icons.swipe_right, color: AppTheme.gray400),
                                    SizedBox(height: 4),
                                    Text('SWIPE RIGHT TO KEEP', style: TextStyle(fontSize: 10, color: AppTheme.gray400)),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Venue Layout Analysis
                            _buildVenueAnalysis(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

      ),
    );
  }

  Widget _buildAICircle() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rings opacity
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.blue600.withOpacity(0.1),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.blue600.withOpacity(0.2),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.blue600.withOpacity(0.3),
            ),
          ),
          // Core
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.blue600, AppTheme.indigo700],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.blue600,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Completion',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.gray700,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '65%',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.blue600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.gray200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: 220, // 65% approximate width
              decoration: BoxDecoration(
                color: AppTheme.blue600,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.indigo100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NETWORKING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryIndigo,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Text(
                '14:00 - 15:00',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Interactive AI Workshop:\nPrompt Engineering 101',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'A hands-on session where attendees collaborate to build complex prompt chains for creative workflows. Includes 15 min Q&A.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Regenerate'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.gray50,
                    foregroundColor: Colors.black,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Keep'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVenueAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VENUE LAYOUT ANALYSIS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.gray600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.gray200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.map, size: 32, color: AppTheme.gray400),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: NetworkImage('https://placeholder.com/heatmap'), // Placeholder
                      fit: BoxFit.cover,
                      opacity: 0.6,
                    ),
                  ),
                  child: const Center(
                     child: Icon(Icons.bar_chart, size: 32, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.gray200)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.auto_awesome, 'Generate', true),
              _buildNavItem(Icons.calendar_today, 'Agenda', false),
              _buildNavItem(Icons.people, 'Speakers', false),
              _buildNavItem(Icons.settings, 'Setup', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? AppTheme.blue600 : AppTheme.gray400,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.blue600 : AppTheme.gray400,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
