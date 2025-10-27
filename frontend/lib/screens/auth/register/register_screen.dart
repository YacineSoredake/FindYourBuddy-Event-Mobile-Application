import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/auth/register/step_email.dart';
import 'package:frontend/screens/auth/register/step_info.dart';
import 'package:frontend/screens/auth/register/verifye_email.dart';
import 'package:provider/provider.dart';
import 'step_avatar.dart';
import 'step_interests.dart';

class RegisterFlowScreen extends StatefulWidget {
  const RegisterFlowScreen({super.key});

  @override
  State<RegisterFlowScreen> createState() => _RegisterFlowScreenState();
}

class _RegisterFlowScreenState extends State<RegisterFlowScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _smoothToPage(int page) {
    _controller.reverse().then((_) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubicEmphasized,
      );
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final steps = [
      const StepEmail(),
      const StepVerifyEmail(), 
      const StepInfo(),
      const StepAvatar(),
      const StepInterests(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != auth.currentStep) {
        _smoothToPage(auth.currentStep);
      }
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, auth),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: steps.length,
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: steps[index],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AuthProvider auth) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color.fromARGB(255, 213, 240, 255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: auth.currentStep > 0
                    ? _circleButton(
                        key: const ValueKey('back'),
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => auth.previousStep(),
                      )
                    : const SizedBox(width: 48),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _getStepTitle(auth.currentStep),
                  key: ValueKey(auth.currentStep),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: auth.currentStep == 0
                    ? _loginButton(context, auth)
                    : const SizedBox(width: 48),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(auth),
        ],
      ),
    );
  }

  Widget _circleButton({
    required Key key,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _loginButton(BuildContext context, AuthProvider auth) {
    return Container(
      key: const ValueKey('login_button'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primary,
      ),
      child: IconButton(
        icon: const Icon(Icons.login, color: Colors.white, size: 22),
        onPressed: () {
          auth.resetRegistration();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    );
  }

  Widget _buildProgressBar(AuthProvider auth) {
    double progress = (auth.currentStep + 1) / AuthProvider.totalSteps;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutExpo,
              height: 8,
              width: MediaQuery.of(context).size.width * 0.85 * progress,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 5, 252, 116),
                    Color.fromARGB(255, 4, 189, 87),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Step ${auth.currentStep + 1} of ${AuthProvider.totalSteps}",
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return "Welcome Aboard";
      case 1:
        return "Tell Us About You";
      case 2:
        return "Choose Your Avatar";
      case 3:
        return "Your Interests";
      default:
        return "Create Account";
    }
  }
}
