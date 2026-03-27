import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/widgets.dart';
import '../providers/app_providers.dart';
import '../theme/app_design_tokens.dart';
import 'widgets/amber_pill_button.dart';
import 'widgets/onboarding_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final PageController _carouselController =
      PageController(viewportFraction: 0.74);
  int _pageIndex = 0;
  int _carouselIndex = 0;
  bool _mediaVisibilityOn = false;

  @override
  void dispose() {
    _pageController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingHolderProvider.notifier).markCompleted();
    if (!mounted) return;
    context.go('/');
  }

  void _goNextPage() {
    if (_pageIndex >= 2) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  TextStyle _headline(BuildContext context) => GoogleFonts.plusJakartaSans(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: AppDesignTokens.textPrimary,
        letterSpacing: -0.5,
      );

  TextStyle _subtitle(BuildContext context) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 1.45,
        color: AppDesignTokens.textSecondary,
        fontWeight: FontWeight.w400,
      );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _pageIndex = i),
            children: [
              _buildWelcome(bottomInset),
              _buildFeatures(bottomInset),
              _buildProfilePreview(bottomInset),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(double bottomInset) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            'Connect Smarter',
            textAlign: TextAlign.center,
            style: _headline(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Chat, share, and collaborate in one place',
            textAlign: TextAlign.center,
            style: _subtitle(context),
          ),
          const Spacer(flex: 3),
          AmberGradientPillButton(
            label: 'Get Started',
            onPressed: _goNextPage,
          ),
          SizedBox(height: 24 + bottomInset),
        ],
      ),
    );
  }

  Widget _buildFeatures(double bottomInset) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Seamless Conversations',
            textAlign: TextAlign.center,
            style: _headline(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Fast, secure messaging with media sharing and reactions.',
            textAlign: TextAlign.center,
            style: _subtitle(context),
          ),
          const SizedBox(height: 28),
          _mockChatColumn(),
          const SizedBox(height: 28),
          SizedBox(
            height: 148,
            child: PageView.builder(
              controller: _carouselController,
              itemCount: 3,
              padEnds: true,
              onPageChanged: (i) => setState(() => _carouselIndex = i),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Transform.rotate(
                    angle: (index - 1) * 0.06,
                    child: _carouselCard(index),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final active = i == _carouselIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: active
                      ? AppDesignTokens.onboardingOrange
                      : Colors.white.withValues(alpha: 0.2),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          AmberGradientPillButton(
            label: 'Next',
            onPressed: _goNextPage,
          ),
        ],
      ),
    );
  }

  Widget _carouselCard(int index) {
    final gradients = [
      const [Color(0xFF5C4033), Color(0xFF8B6914)],
      const [Color(0xFF3D4A5C), Color(0xFF6B7F9F)],
      const [Color(0xFF4A3D2E), Color(0xFF7D6E58)],
    ];
    final g = gradients[index % gradients.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: g,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            LucideIcons.image,
            size: 40,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  Widget _mockChatColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: GlassCard(
              borderRadius: AppDesignTokens.onboardingGlassRadius,
              borderColor: Colors.white.withValues(alpha: 0.14),
              borderWidth: 1,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's meet tomorrow at 2 PM!",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: AppDesignTokens.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            AppDesignTokens.onboardingAmber.withValues(
                          alpha: 0.35,
                        ),
                        child: Text(
                          'G',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Gerald',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GlassCard(
                  borderRadius: AppDesignTokens.onboardingGlassRadius,
                  borderColor: AppDesignTokens.onboardingAmber.withValues(
                    alpha: 0.35,
                  ),
                  borderWidth: 1,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Text(
                    'Sounds perfect! 🤩',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: AppDesignTokens.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _reactionChip(LucideIcons.thumbsUp),
                    const SizedBox(width: 8),
                    _reactionChip(LucideIcons.folder),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _reactionChip(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Icon(icon, size: 16, color: AppDesignTokens.textSecondary),
    );
  }

  Widget _buildProfilePreview(double bottomInset) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _glassIconButton(
              icon: LucideIcons.arrowLeft,
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppDesignTokens.onboardingAmber.withValues(alpha: 0.5),
                      AppDesignTokens.onboardingOrange.withValues(alpha: 0.4),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'KD',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Khadija Dubois',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppDesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '+1 654-121-1234',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: AppDesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          GlassCard(
            borderRadius: AppDesignTokens.onboardingGlassRadius,
            borderColor: Colors.white.withValues(alpha: 0.12),
            borderWidth: 1,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: Row(
              children: [
                _statColumn('Messages', '12,145'),
                _statDivider(),
                _statColumn('Groups', '94'),
                _statDivider(),
                _statColumn('Spaces', '48'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Media and photos',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppDesignTokens.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    LucideIcons.chevronRight,
                    color: AppDesignTokens.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 72,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(
                              AppDesignTokens.onboardingGlowDeep,
                              AppDesignTokens.onboardingAmber,
                              0.2 + i * 0.15,
                            )!,
                            Color.lerp(
                              AppDesignTokens.surface,
                              AppDesignTokens.onboardingOrange,
                              0.15 + i * 0.1,
                            )!,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _settingsRow(
            icon: LucideIcons.bell,
            title: 'Notification',
            trailing: Icon(
              LucideIcons.chevronRight,
              color: AppDesignTokens.textSecondary,
              size: 22,
            ),
            onTap: () {},
          ),
          _settingsRow(
            icon: LucideIcons.imagePlus,
            title: 'Media visibility',
            trailing: Switch.adaptive(
              value: _mediaVisibilityOn,
              activeTrackColor:
                  AppDesignTokens.onboardingAmber.withValues(alpha: 0.55),
              activeThumbColor: Colors.white,
              onChanged: (v) => setState(() => _mediaVisibilityOn = v),
            ),
          ),
          _settingsRow(
            icon: LucideIcons.bookmark,
            title: 'Lock Chat',
            trailing: Icon(
              LucideIcons.chevronRight,
              color: AppDesignTokens.textSecondary,
              size: 22,
            ),
            onTap: () {},
          ),
          const Spacer(),
          AmberGradientPillButton(
            label: 'Continue',
            onPressed: _finishOnboarding,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Sign In',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppDesignTokens.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$label:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppDesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppDesignTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppDesignTokens.textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppDesignTokens.textPrimary,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.08),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: AppDesignTokens.textPrimary, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
