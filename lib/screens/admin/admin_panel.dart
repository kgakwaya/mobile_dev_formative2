import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import '../../models/startup_model.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final startupProvider = Provider.of<StartupProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Console', style: TextStyle(fontSize: 14, color: AppColors.error)),
            Text('ALU Venture Verification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Description Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: AppColors.error, size: 28),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incubator Officer Authorization',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Review and verify student-led startups to allow them to recruit interns on the platform.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Pending Verification Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            // Streamed list of unverified startups
            Expanded(
              child: StreamBuilder<List<StartupModel>>(
                stream: startupProvider.unverifiedStartupsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.error));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final requests = snapshot.data ?? [];

                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                          const SizedBox(height: 16),
                          const Text(
                            'All startups are verified!\nNo pending requests.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final startup = requests[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    startup.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      startup.cohort,
                                      style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sector: ${startup.industry}',
                                style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const Divider(height: 24),
                              
                              Text(
                                startup.description,
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  // Reject/Delete request
                                  OutlinedButton(
                                    onPressed: () async {
                                      await startupProvider.deleteStartup(startup.id);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                  const Spacer(),
                                  // Verify Startup Button
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.verified_user_outlined, size: 18),
                                    label: const Text('Verify Venture'),
                                    onPressed: () async {
                                      final success = await startupProvider.verifyStartup(startup.id);
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${startup.name} has been verified successfully!'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
