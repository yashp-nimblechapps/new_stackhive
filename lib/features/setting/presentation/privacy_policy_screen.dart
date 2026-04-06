import 'package:flutter/material.dart';
import 'package:stackhive/core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final policies = [
      PolicyItem(
        icon: Icons.lock_outline,
        title: 'User Data Collection',
        description:
            'We collect basic information such as your name, email address, and account ID to create and manage your StackHive account.',
      ),
      PolicyItem(
        icon: Icons.analytics_outlined,
        title: 'Usage of Data',
        description:
            'Your information is used to improve the platform, provide personalized experience, and maintain community standards.',
      ),
      PolicyItem(
        icon: Icons.article_outlined,
        title: 'Content Ownership',
        description:
            'Questions and answers posted by users remain visible on the platform to help other users learn and solve problems.',
      ),
      PolicyItem(
        icon: Icons.shield_outlined,
        title: 'Community Safety',
        description:
            'StackHive may monitor and moderate content to ensure users follow community guidelines and maintain respectful discussions.',
      ),
      PolicyItem(
        icon: Icons.security_outlined,
        title: 'Account Security',
        description:
            'We use secure authentication services to protect your account and personal information.',
      ),
      PolicyItem(
        icon: Icons.admin_panel_settings_outlined,
        title: 'Admin Actions',
        description:
            'If a user violates community policies, administrators may restrict features such as posting questions, answering, or voting.',
      ),
      PolicyItem(
        icon: Icons.cloud_outlined,
        title: "Third-Party Services",
        description:
            "StackHive may use trusted services like Firebase to store and process data securely.",
      ),
      PolicyItem(
        icon: Icons.update_outlined,
        title: "Policy Updates",
        description:
            "These policies may be updated periodically to improve security and transparency.",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.darkBackground : AppColors.lightBackground, 
        elevation: 0,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// INTRO CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              "At StackHive, we respect your privacy and are also committed to protecting your personal information. "
              "This policy explains how your data is collected, used, and protected while using the platform.",
              style: theme.textTheme.bodyMedium, textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          /// POLICY CARDS
          ...policies.map(
            (policy) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PolicyCard(policy: policy),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final PolicyItem policy;

  const _PolicyCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ICON CONTAINER
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              policy.icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          /// TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  policy.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  policy.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PolicyItem {
  final IconData icon;
  final String title;
  final String description;

  PolicyItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}