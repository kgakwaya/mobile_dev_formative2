import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/opportunity_model.dart';

class ApplyScreen extends StatefulWidget {
  final OpportunityModel opportunity;

  const ApplyScreen({super.key, required this.opportunity});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pitchController = TextEditingController();

  @override
  void dispose() {
    _pitchController.dispose();
    super.dispose();
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) return;

      final success = await appProvider.applyToOpportunity(
        opportunityId: widget.opportunity.id,
        opportunityTitle: widget.opportunity.title,
        startupId: widget.opportunity.startupId,
        startupName: widget.opportunity.startupName,
        studentId: user.uid,
        studentName: user.displayName,
        studentEmail: user.email,
        studentSkills: user.skills,
        pitch: _pitchController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Close ApplyScreen
        Navigator.pop(context); // Go back to Feed/Dashboard
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appProvider.error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<ApplicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Application'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Pitching for:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                widget.opportunity.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                'at ${widget.opportunity.startupName}',
                style: const TextStyle(fontSize: 16, color: AppColors.secondary),
              ),
              const Divider(height: 40),

              // Tips Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.secondary, size: 22),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Explain briefly why you are interested in this venture and how your current skills match what they are looking for.",
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pitch input field
              TextFormField(
                controller: _pitchController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Why are you a good fit?',
                  hintText: 'Share details of your experience, projects, or why you want to support this startup...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your interest pitch';
                  }
                  if (value.trim().length < 20) {
                    return 'Please write a slightly longer pitch (min 20 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: appProvider.isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: appProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
