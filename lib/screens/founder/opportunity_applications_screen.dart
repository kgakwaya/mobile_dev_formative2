import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/application_provider.dart';
import '../../models/opportunity_model.dart';
import '../../models/application_model.dart';

class OpportunityApplicationsScreen extends StatelessWidget {
  final OpportunityModel opportunity;

  const OpportunityApplicationsScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<ApplicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${opportunity.title} Applicants'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: appProvider.startupApplicationsStream(opportunity.startupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allApps = snapshot.data ?? [];
          // Filter specifically for this opportunity
          final apps = allApps.where((a) => a.opportunityId == opportunity.id).toList();

          if (apps.isEmpty) {
            return const Center(
              child: Text(
                'No applications received yet for this role.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            itemCount: apps.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final app = apps[index];
              return ApplicantCard(application: app);
            },
          );
        },
      ),
    );
  }
}

class ApplicantCard extends StatefulWidget {
  final ApplicationModel application;

  const ApplicantCard({super.key, required this.application});

  @override
  State<ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<ApplicantCard> {
  final _feedbackController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _showStatusDialog(String newStatus) {
    _feedbackController.text = widget.application.feedback;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Status to: $newStatus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add optional feedback or instructions for ${widget.application.studentName}:',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Please check your email for the calendar link, or let\'s sync next week.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
              await appProvider.updateApplicationStatus(
                applicationId: widget.application.id,
                status: newStatus,
                feedback: _feedbackController.text.trim(),
              );
            },
            child: const Text('Update', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    Color statusColor = AppColors.textMuted;
    switch (app.status) {
      case 'Pending':
        statusColor = AppColors.accent;
        break;
      case 'Shortlisted':
        statusColor = AppColors.secondary;
        break;
      case 'Interviewing':
        statusColor = Colors.purpleAccent;
        break;
      case 'Accepted':
        statusColor = AppColors.success;
        break;
      case 'Rejected':
        statusColor = AppColors.error;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    app.studentName.isNotEmpty ? app.studentName[0].toUpperCase() : 'S',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(app.studentEmail, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    app.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Short bio or Pitch summary
            const Text('Candidate Pitch:', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              app.pitch,
              maxLines: _isExpanded ? 100 : 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary),
            ),
            
            // Expand button
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  _isExpanded ? 'Show less' : 'Read full pitch...',
                  style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Candidate Skills
            const Text('Skills:', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: app.studentSkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(skill, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                );
              }).toList(),
            ),

            if (app.feedback.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Current Feedback:', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(app.feedback, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
            ],

            const Divider(height: 24),

            // Action Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionChip('Shortlist', AppColors.secondary),
                  const SizedBox(width: 8),
                  _buildActionChip('Interviewing', Colors.purpleAccent),
                  const SizedBox(width: 8),
                  _buildActionChip('Accepted', AppColors.success),
                  const SizedBox(width: 8),
                  _buildActionChip('Rejected', AppColors.error),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(String label, Color color) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color.withOpacity(0.5)),
      onPressed: () => _showStatusDialog(label),
    );
  }
}
