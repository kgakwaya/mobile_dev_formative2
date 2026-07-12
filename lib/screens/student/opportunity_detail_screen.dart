import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/opportunity_model.dart';
import 'apply_screen.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final OpportunityModel opportunity;
  final int skillsMatchPercentage;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunity,
    required this.skillsMatchPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internship Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              decoration: AppTheme.glassDecoration(
                color: AppColors.surface,
                opacity: 0.6,
                borderRadius: 20,
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    opportunity.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Startup name & verified check
                  Row(
                    children: [
                      Text(
                        opportunity.startupName,
                        style: const TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      if (opportunity.startupVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: AppColors.success, size: 18),
                        const SizedBox(width: 4),
                        const Text(
                          'ALU Incubation Verified',
                          style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: 32),

                  // Info grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn(Icons.location_on_outlined, 'Location', opportunity.locationType, AppColors.secondary),
                      _buildInfoColumn(Icons.schedule, 'Duration', opportunity.duration, AppColors.accent),
                      _buildInfoColumn(Icons.access_time_rounded, 'Hours', opportunity.hoursPerWeek, Colors.purpleAccent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            _buildSectionTitle('Role Description'),
            Text(
              opportunity.description,
              style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),

            // Skills Match
            _buildSectionTitle('Required Skills & Match'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (skillsMatchPercentage > 0) ...[
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Your skill match is $skillsMatchPercentage%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: opportunity.skillsRequired.map((skill) {
                      final hasSkill = user.skills.any((us) => us.toLowerCase() == skill.toLowerCase());
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasSkill ? AppColors.success.withOpacity(0.12) : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasSkill ? AppColors.success.withOpacity(0.4) : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasSkill ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                              size: 14,
                              color: hasSkill ? AppColors.success : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              skill,
                              style: TextStyle(
                                fontSize: 12,
                                color: hasSkill ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: hasSkill ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Apply Button wrapper (FutureBuilder or StreamBuilder to check if already applied)
            FutureBuilder<bool>(
              future: appProvider.hasApplied(user.uid, opportunity.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hasApplied = snapshot.data ?? false;

                if (hasApplied) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(width: 8),
                        const Text(
                          'You have applied to this opportunity',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplyScreen(opportunity: opportunity),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    child: const Text('Apply Now'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
