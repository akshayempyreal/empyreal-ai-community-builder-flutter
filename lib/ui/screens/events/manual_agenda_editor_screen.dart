import 'package:empyreal_ai_community_builder_flutter/models/agenda_item.dart';
import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:empyreal_ai_community_builder_flutter/models/user.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class ManualAgendaEditorScreen extends StatelessWidget {
  final Event event;
  final List<AgendaItem> existingAgenda;
  final Function(List<AgendaItem>) onSaveAgenda;
  final VoidCallback onBack;
  final User user;

  const ManualAgendaEditorScreen({
    super.key,
    required this.event,
    required this.existingAgenda,
    required this.onSaveAgenda,
    required this.onBack,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Edit Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => onSaveAgenda(existingAgenda),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildEditorHelper(context, isDark),
            const SizedBox(height: 32),
            ...existingAgenda.map((item) => _buildItemEditor(context, item, isDark)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Agenda Item'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PrimaryButton(
            text: 'Save Schedule',
            onPressed: () => onSaveAgenda(existingAgenda),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorHelper(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'You can manually adjust times and details for "${event.name}".',
              style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemEditor(BuildContext context, AgendaItem item, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.title,
                    decoration: const InputDecoration(labelText: 'Item Title'),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, color: AppColors.error)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.startTime,
                    decoration: const InputDecoration(labelText: 'Start Time', prefixIcon: Icon(Icons.access_time)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: item.endTime,
                    decoration: const InputDecoration(labelText: 'End Time', prefixIcon: Icon(Icons.access_time_filled)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
