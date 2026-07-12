import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/opportunity_model.dart';
import '../../models/application_model.dart';
import 'opportunity_applications_screen.dart';

class FounderDashboard extends StatefulWidget {
  const FounderDashboard({super.key});

  @override
  State<FounderDashboard> createState() => _FounderDashboardState();
}

class _FounderDashboardState extends State<FounderDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const ActivePostingsTab(),
    const PostOpportunityTab(),
    const FounderVentureProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center_outlined),
            activeIcon: Icon(Icons.business_center),
            label: 'My Postings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Post Role',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Venture Profile',
          ),
        ],
      ),
    );
  }
}

// ==================== MY POSTINGS TAB ====================
class ActivePostingsTab extends StatelessWidget {
  const ActivePostingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final oppProvider = Provider.of<OpportunityProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);
    
    final startup = authProvider.currentStartup;

    if (startup == null) {
      return const Scaffold(
        body: Center(child: Text('Loading startup details...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(startup.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Venture Dashboard', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
      body: StreamBuilder<List<OpportunityModel>>(
        stream: oppProvider.startupOpportunitiesStream(startup.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final opps = snapshot.data ?? [];

          if (opps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.post_add, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text(
                      "You haven't posted any opportunities yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return StreamBuilder<List<ApplicationModel>>(
            stream: appProvider.startupApplicationsStream(startup.id),
            builder: (context, appSnapshot) {
              final apps = appSnapshot.data ?? [];

              return ListView.builder(
                itemCount: opps.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final opp = opps[index];
                  // Filter applications for this specific opportunity
                  final oppApps = apps.where((a) => a.opportunityId == opp.id).toList();
                  final applicantCount = oppApps.length;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(opp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Text(opp.roleType, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              // Status badge (Open/Closed)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: opp.isClosed ? AppColors.error.withOpacity(0.12) : AppColors.success.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: opp.isClosed ? AppColors.error.withOpacity(0.4) : AppColors.success.withOpacity(0.4)),
                                ),
                                child: Text(
                                  opp.isClosed ? 'Closed' : 'Open',
                                  style: TextStyle(color: opp.isClosed ? AppColors.error : AppColors.success, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          
                          // Applicant count and settings buttons
                          Row(
                            children: [
                              GestureDetector(
                                onTap: applicantCount > 0 ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OpportunityApplicationsScreen(opportunity: opp),
                                    ),
                                  );
                                } : null,
                                child: Row(
                                  children: [
                                    Icon(Icons.people_outline, size: 20, color: applicantCount > 0 ? AppColors.primary : AppColors.textMuted),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$applicantCount Candidate${applicantCount == 1 ? '' : 's'}',
                                      style: TextStyle(
                                        color: applicantCount > 0 ? AppColors.primary : AppColors.textMuted,
                                        fontWeight: applicantCount > 0 ? FontWeight.bold : FontWeight.normal,
                                        decoration: applicantCount > 0 ? TextDecoration.underline : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              
                              // Change Status Button
                              IconButton(
                                icon: Icon(
                                  opp.isClosed ? Icons.play_arrow_outlined : Icons.pause_circle_outline,
                                  color: opp.isClosed ? AppColors.success : AppColors.accent,
                                ),
                                tooltip: opp.isClosed ? 'Reopen listing' : 'Close listing',
                                onPressed: () => oppProvider.toggleOpportunityStatus(opp.id, !opp.isClosed),
                              ),
                              
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                tooltip: 'Delete listing',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Opportunity?'),
                                      content: const Text('This will delete this internship listing and all its candidate submissions. This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            await oppProvider.deleteOpportunity(opp.id);
                                          },
                                          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
          );
        },
      ),
    );
  }
}

// ==================== POST OPPORTUNITY TAB ====================
class PostOpportunityTab extends StatefulWidget {
  const PostOpportunityTab({super.key});

  @override
  State<PostOpportunityTab> createState() => _PostOpportunityTabState();
}

class _PostOpportunityTabState extends State<PostOpportunityTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _hoursController = TextEditingController();
  final _skillsController = TextEditingController();

  String _selectedRoleType = 'Software Development';
  String _selectedLocationType = 'Remote';

  final List<String> _roleTypes = [
    'Software Development',
    'UI/UX Design',
    'Marketing',
    'Operations',
    'Business Analysis',
    'Content Creation',
    'Research',
  ];

  final List<String> _locationTypes = ['Remote', 'Hybrid', 'On-Campus'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _hoursController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final oppProvider = Provider.of<OpportunityProvider>(context, listen: false);
      
      final startup = authProvider.currentStartup;
      if (startup == null) return;

      // Split comma skills
      final skillsList = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final success = await oppProvider.postOpportunity(
        startupId: startup.id,
        startupName: startup.name,
        startupVerified: startup.isVerified,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        roleType: _selectedRoleType,
        skillsRequired: skillsList,
        locationType: _selectedLocationType,
        duration: _durationController.text.trim(),
        hoursPerWeek: _hoursController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opportunity posted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Clear forms
        _titleController.clear();
        _descController.clear();
        _durationController.clear();
        _hoursController.clear();
        _skillsController.clear();
        setState(() {
          _selectedRoleType = 'Software Development';
          _selectedLocationType = 'Remote';
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(oppProvider.error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final oppProvider = Provider.of<OpportunityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post New Internship'),
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Internship Title', hintText: 'e.g. Flutter Mobile Engineer'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedRoleType,
                decoration: const InputDecoration(labelText: 'Role Sector'),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRoleType = val);
                },
                items: _roleTypes.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Role Description & Tasks',
                  hintText: 'Describe the responsibilities, project scope, and what the intern will learn...',
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLocationType,
                      decoration: const InputDecoration(labelText: 'Location'),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLocationType = val);
                      },
                      items: _locationTypes.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(labelText: 'Duration', hintText: 'e.g. 3 Months'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter duration' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hoursController,
                      decoration: const InputDecoration(labelText: 'Workload', hintText: 'e.g. 15 hrs/week'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter hours' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(labelText: 'Skills Required', hintText: 'e.g. Flutter, Dart, Git'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter skills needed' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: oppProvider.isLoading ? null : _submit,
                child: oppProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Post Opportunity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== VENTURE PROFILE TAB ====================
class FounderVentureProfileTab extends StatefulWidget {
  const FounderVentureProfileTab({super.key});

  @override
  State<FounderVentureProfileTab> createState() => _FounderVentureProfileTabState();
}

class _FounderVentureProfileTabState extends State<FounderVentureProfileTab> {
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _cohortController = TextEditingController();
  final _descController = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _cohortController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _loadStartupData(AuthProvider auth) {
    if (auth.currentStartup != null && !_isEditing) {
      final s = auth.currentStartup!;
      _nameController.text = s.name;
      _industryController.text = s.industry;
      _cohortController.text = s.cohort;
      _descController.text = s.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final startup = authProvider.currentStartup;

    if (startup == null) return const SizedBox();
    _loadStartupData(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: _isEditing ? AppColors.success : AppColors.primary),
            onPressed: () async {
              if (_isEditing) {
                await authProvider.updateStartupProfile(
                  name: _nameController.text.trim(),
                  industry: _industryController.text.trim(),
                  description: _descController.text.trim(),
                  cohort: _cohortController.text.trim(),
                );
                setState(() => _isEditing = false);
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Incubator Verification Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: startup.isVerified
                    ? AppColors.success.withOpacity(0.08)
                    : AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: startup.isVerified ? AppColors.success.withOpacity(0.4) : AppColors.accent.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    startup.isVerified ? Icons.verified : Icons.hourglass_empty,
                    color: startup.isVerified ? AppColors.success : AppColors.accent,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startup.isVerified ? 'Venture Verified' : 'Verification Pending',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: startup.isVerified ? AppColors.success : AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          startup.isVerified
                              ? 'Your startup is officially recognized at ALU. Students can view verified postings.'
                              : 'Incubator staff will verify your venture cohort info (${startup.cohort}) to enable verified status.',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isEditing) ...[
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Startup Name')),
              const SizedBox(height: 16),
              TextField(controller: _industryController, decoration: const InputDecoration(labelText: 'Industry Sector')),
              const SizedBox(height: 16),
              TextField(controller: _cohortController, decoration: const InputDecoration(labelText: 'Incubation Program / Cohort')),
              const SizedBox(height: 16),
              TextField(controller: _descController, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
            ] else ...[
              _buildFieldView('Venture Name', startup.name),
              const SizedBox(height: 16),
              _buildFieldView('Industry Sector', startup.industry),
              const SizedBox(height: 16),
              _buildFieldView('ALU Cohort', startup.cohort),
              const SizedBox(height: 16),
              _buildFieldView('Description', startup.description),
            ],

            const SizedBox(height: 40),
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                onPressed: () => authProvider.logout(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldView(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          value.isNotEmpty ? value : 'Not specified',
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4),
        ),
        const Divider(height: 24),
      ],
    );
  }
}
