import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/opportunity_model.dart';
import 'opportunity_detail_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const OpportunityFeedTab(),
    const StudentApplicationsTab(),
    const BookmarksTab(),
    const StudentProfileTab(),
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
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==================== EXPLORE FEED TAB ====================
class OpportunityFeedTab extends StatefulWidget {
  const OpportunityFeedTab({super.key});

  @override
  State<OpportunityFeedTab> createState() => _OpportunityFeedTabState();
}

class _OpportunityFeedTabState extends State<OpportunityFeedTab> {
  String _searchQuery = '';
  String _selectedRoleType = 'All';
  String _selectedLocationType = 'All';
  bool _onlyVerified = false;

  final List<String> _roleTypes = [
    'All',
    'Software Development',
    'UI/UX Design',
    'Marketing',
    'Operations',
    'Business Analysis',
    'Content Creation',
    'Research',
  ];

  final List<String> _locationTypes = ['All', 'Remote', 'Hybrid', 'On-Campus'];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final oppProvider = Provider.of<OpportunityProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.displayName}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const Text('ALU Opportunities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
      body: Column(
        children: [
          // Search & Filter Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search title, skills or startups...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          
          // Role & Location Quick Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Verified Filter Chip
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: _onlyVerified ? Colors.white : AppColors.success),
                      const SizedBox(width: 4),
                      const Text('Verified Startups Only'),
                    ],
                  ),
                  selected: _onlyVerified,
                  onSelected: (val) => setState(() => _onlyVerified = val),
                  selectedColor: AppColors.success.withOpacity(0.3),
                  checkmarkColor: Colors.white,
                ),
                const SizedBox(width: 8),
                // Role Type Dropdown Widget
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRoleType,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRoleType = val);
                      },
                      items: _roleTypes.map((role) {
                        return DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Location Type Dropdown Widget
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLocationType,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLocationType = val);
                      },
                      items: _locationTypes.map((loc) {
                        return DropdownMenuItem(value: loc, child: Text(loc, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Streamed list of open opportunities
          Expanded(
            child: StreamBuilder<List<OpportunityModel>>(
              stream: oppProvider.openOpportunitiesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
                }

                final opps = snapshot.data ?? [];
                
                // Client-side advanced filtering
                final filteredOpps = opps.where((opp) {
                  final matchesSearch = opp.title.toLowerCase().contains(_searchQuery) ||
                      opp.startupName.toLowerCase().contains(_searchQuery) ||
                      opp.skillsRequired.any((skill) => skill.toLowerCase().contains(_searchQuery)) ||
                      opp.description.toLowerCase().contains(_searchQuery);
                      
                  final matchesRole = _selectedRoleType == 'All' || opp.roleType == _selectedRoleType;
                  final matchesLocation = _selectedLocationType == 'All' || opp.locationType == _selectedLocationType;
                  final matchesVerified = !_onlyVerified || opp.startupVerified;
                  
                  return matchesSearch && matchesRole && matchesLocation && matchesVerified;
                }).toList();

                if (filteredOpps.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          const Text('No opportunities match your filters.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                }

                return StreamBuilder<List<String>>(
                  stream: oppProvider.userBookmarkIdsStream(user.uid),
                  builder: (context, bookmarkSnapshot) {
                    final bookmarkedIds = bookmarkSnapshot.data ?? [];

                    return ListView.builder(
                      itemCount: filteredOpps.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final opp = filteredOpps[index];
                        final isSaved = bookmarkedIds.contains(opp.id);
                        
                        // Calculate skills match
                        int matchPercentage = 0;
                        if (opp.skillsRequired.isNotEmpty && user.skills.isNotEmpty) {
                          int matches = 0;
                          for (var reqSkill in opp.skillsRequired) {
                            if (user.skills.any((us) => us.toLowerCase() == reqSkill.toLowerCase())) {
                              matches++;
                            }
                          }
                          matchPercentage = ((matches / opp.skillsRequired.length) * 100).round();
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OpportunityDetailScreen(opportunity: opp, skillsMatchPercentage: matchPercentage),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header: Title & Bookmark
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(opp.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(opp.startupName, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                                if (opp.startupVerified) ...[
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.verified, color: AppColors.success, size: 16),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isSaved ? Icons.favorite : Icons.favorite_border,
                                          color: isSaved ? AppColors.error : AppColors.textSecondary,
                                        ),
                                        onPressed: () => oppProvider.toggleBookmark(user.uid, opp.id),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  
                                  // Detail Tags
                                  Row(
                                    children: [
                                      _buildTag(Icons.location_on_outlined, opp.locationType, AppColors.secondary),
                                      const SizedBox(width: 12),
                                      _buildTag(Icons.schedule_outlined, opp.duration, AppColors.accent),
                                      const Spacer(),
                                      // Skill Match Badge
                                      if (user.skills.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: matchPercentage > 50 
                                                ? AppColors.success.withOpacity(0.12)
                                                : AppColors.border,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: matchPercentage > 50 
                                                  ? AppColors.success.withOpacity(0.4)
                                                  : AppColors.borderLight,
                                            ),
                                          ),
                                          child: Text(
                                            '$matchPercentage% Match',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: matchPercentage > 50 ? AppColors.success : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Required Skills Row
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: opp.skillsRequired.take(3).map((skill) {
                                      final isMatched = user.skills.any((us) => us.toLowerCase() == skill.toLowerCase());
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isMatched 
                                              ? AppColors.secondary.withOpacity(0.12)
                                              : AppColors.surfaceLight.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(6),
                                          border: isMatched ? Border.all(color: AppColors.secondary.withOpacity(0.3)) : null,
                                        ),
                                        child: Text(
                                          skill,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isMatched ? AppColors.secondary : AppColors.textSecondary,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ==================== APPLICATIONS TAB ====================
class StudentApplicationsTab extends StatelessWidget {
  const StudentApplicationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: appProvider.studentApplicationsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final apps = snapshot.data ?? [];

          if (apps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text(
                      "You haven't applied to any opportunities yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: apps.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final app = apps[index];
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
                                Text(app.opportunityTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(app.startupName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withOpacity(0.4)),
                            ),
                            child: Text(
                              app.status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Applied on: ${DateFormat('MMM dd, yyyy').format(app.createdAt)}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      
                      if (app.feedback.isNotEmpty) ...[
                        const Divider(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 14, color: statusColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Startup Feedback:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(app.feedback, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== BOOKMARKS TAB ====================
class BookmarksTab extends StatelessWidget {
  const BookmarksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final oppProvider = Provider.of<OpportunityProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Internships'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<String>>(
        stream: oppProvider.userBookmarkIdsStream(user.uid),
        builder: (context, bookmarkSnapshot) {
          if (bookmarkSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }
          final bookmarkedIds = bookmarkSnapshot.data ?? [];

          if (bookmarkedIds.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('Save roles you love and check them here later.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  ],
                ),
              ),
            );
          }

          return StreamBuilder<List<OpportunityModel>>(
            stream: oppProvider.openOpportunitiesStream,
            builder: (context, oppSnapshot) {
              if (oppSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final opps = oppSnapshot.data ?? [];
              final savedOpps = opps.where((o) => bookmarkedIds.contains(o.id)).toList();

              if (savedOpps.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_clock_outlined, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        const Text('Your saved opportunities have closed.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: savedOpps.length,
                itemBuilder: (context, index) {
                  final opp = savedOpps[index];
                  return Card(
                    child: ListTile(
                      title: Text(opp.title),
                      subtitle: Text(opp.startupName),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OpportunityDetailScreen(opportunity: opp, skillsMatchPercentage: 0),
                          ),
                        );
                      },
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

// ==================== PROFILE TAB ====================
class StudentProfileTab extends StatefulWidget {
  const StudentProfileTab({super.key});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _majorController = TextEditingController();
  final _gradYearController = TextEditingController();
  final _skillsController = TextEditingController();
  final _portfolioController = TextEditingController();
  
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _majorController.dispose();
    _gradYearController.dispose();
    _skillsController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  void _loadUserData(AuthProvider auth) {
    if (auth.currentUser != null && !_isEditing) {
      final user = auth.currentUser!;
      _nameController.text = user.displayName;
      _bioController.text = user.bio;
      _majorController.text = user.major;
      _gradYearController.text = user.gradYear;
      _skillsController.text = user.skills.join(', ');
      _portfolioController.text = user.portfolioUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const SizedBox();
    _loadUserData(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: _isEditing ? AppColors.success : AppColors.secondary),
            onPressed: () async {
              if (_isEditing) {
                // Save profile details
                final skillsList = _skillsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                await authProvider.updateProfile(
                  displayName: _nameController.text.trim(),
                  bio: _bioController.text.trim(),
                  skills: skillsList,
                  major: _majorController.text.trim(),
                  gradYear: _gradYearController.text.trim(),
                  portfolioUrl: _portfolioController.text.trim(),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.secondary.withOpacity(0.2),
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'S',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_isEditing) ...[
                    Text(user.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${user.major} • Class of ${user.gradYear}', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Editable / View Fields
            if (_isEditing) ...[
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 16),
              TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio')),
              const SizedBox(height: 16),
              TextField(controller: _majorController, decoration: const InputDecoration(labelText: 'Major')),
              const SizedBox(height: 16),
              TextField(controller: _gradYearController, decoration: const InputDecoration(labelText: 'Graduation Year')),
              const SizedBox(height: 16),
              TextField(controller: _skillsController, decoration: const InputDecoration(labelText: 'Skills (comma separated)')),
              const SizedBox(height: 16),
              TextField(controller: _portfolioController, decoration: const InputDecoration(labelText: 'Portfolio URL')),
            ] else ...[
              _buildSectionTitle('Bio'),
              Text(user.bio.isNotEmpty ? user.bio : 'No bio added yet.', style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Skills Portfolio'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.skills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Portfolio Links'),
              Row(
                children: [
                  const Icon(Icons.link, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.portfolioUrl.isNotEmpty ? user.portfolioUrl : 'No links added.',
                      style: const TextStyle(color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
