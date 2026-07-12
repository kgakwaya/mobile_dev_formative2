import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Account details
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  
  String _selectedRole = 'student'; // 'student' or 'founder'
  
  // Student fields
  final _majorController = TextEditingController();
  final _gradYearController = TextEditingController();
  final _skillsController = TextEditingController(); // Comma separated
  final _portfolioController = TextEditingController();

  // Founder fields
  final _startupNameController = TextEditingController();
  final _startupIndustryController = TextEditingController();
  final _startupCohortController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _majorController.dispose();
    _gradYearController.dispose();
    _skillsController.dispose();
    _portfolioController.dispose();
    _startupNameController.dispose();
    _startupIndustryController.dispose();
    _startupCohortController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Parse skills comma list
      List<String> skillsList = [];
      if (_selectedRole == 'student' && _skillsController.text.isNotEmpty) {
        skillsList = _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _nameController.text.trim(),
        role: _selectedRole,
        bio: _bioController.text.trim(),
        skills: skillsList,
        major: _majorController.text.trim(),
        gradYear: _gradYearController.text.trim(),
        portfolioUrl: _portfolioController.text.trim(),
        startupName: _startupNameController.text.trim(),
        startupIndustry: _startupIndustryController.text.trim(),
        startupDescription: _bioController.text.trim(), // Use bio controller for startup description too
        startupCohort: _startupCohortController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Welcome to ALU VentureLink.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Go back to AuthGate, which will route correctly
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              Color(0xFF0F172A),
              Color(0xFF1E1E38),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join the ALU venture network',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Role Selector
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'student'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedRole == 'student'
                                ? AppColors.secondary.withOpacity(0.15)
                                : AppColors.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedRole == 'student'
                                  ? AppColors.secondary
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                color: _selectedRole == 'student' ? AppColors.secondary : AppColors.textSecondary,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ALU Student',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedRole == 'student' ? AppColors.textPrimary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'founder'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedRole == 'founder'
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedRole == 'founder'
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Column(
                            children: [
                              Icon(
                                Icons.business_outlined,
                                color: _selectedRole == 'founder' ? AppColors.primary : AppColors.textSecondary,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Startup Founder',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedRole == 'founder' ? AppColors.textPrimary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Register Form
                Container(
                  decoration: AppTheme.glassDecoration(
                    color: AppColors.surface,
                    opacity: 0.7,
                    borderRadius: 24,
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Common fields: Full Name, Email, Password, Bio
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _bioController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: _selectedRole == 'student' ? 'Brief Bio' : 'Founder Bio',
                            prefixIcon: const Icon(Icons.description_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // STUDENT FIELDS
                        if (_selectedRole == 'student') ...[
                          TextFormField(
                            controller: _majorController,
                            decoration: const InputDecoration(
                              labelText: 'ALU Degree Program (Major)',
                              prefixIcon: Icon(Icons.school_outlined),
                              hintText: 'e.g. Software Engineering',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please specify your major';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _gradYearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Graduation Year',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter graduation year';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _skillsController,
                            decoration: const InputDecoration(
                              labelText: 'Skills (comma separated)',
                              prefixIcon: Icon(Icons.auto_awesome_outlined),
                              hintText: 'e.g. Flutter, UI Design, Python',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter at least one skill';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _portfolioController,
                            decoration: const InputDecoration(
                              labelText: 'Portfolio / GitHub Link',
                              prefixIcon: Icon(Icons.link_outlined),
                            ),
                          ),
                        ],

                        // FOUNDER FIELDS
                        if (_selectedRole == 'founder') ...[
                          TextFormField(
                            controller: _startupNameController,
                            decoration: const InputDecoration(
                              labelText: 'Startup Name',
                              prefixIcon: Icon(Icons.business_center_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter startup name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _startupIndustryController,
                            decoration: const InputDecoration(
                              labelText: 'Industry Sector',
                              prefixIcon: Icon(Icons.category_outlined),
                              hintText: 'e.g. EdTech, FinTech, Creative Agency',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please specify startup industry';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _startupCohortController,
                            decoration: const InputDecoration(
                              labelText: 'Incubation Program Cohort',
                              prefixIcon: Icon(Icons.card_membership_outlined),
                              hintText: 'e.g. ALU Incubation Cohort 2025',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter program/cohort identifier';
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Register Button
                        ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedRole == 'student' ? AppColors.secondary : AppColors.primary,
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Register Now'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
