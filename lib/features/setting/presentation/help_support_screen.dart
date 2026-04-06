import 'package:flutter/material.dart';
import 'package:stackhive/core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final faqs = [
      FAQItem(
        question: "How to post a question?",
        answer:
            "Go to the Ask Question screen from the bottom navigation bar. "
            "Enter a clear title, detailed description, and relevant tags before submitting.",
      ),
      FAQItem(
        question: "How to post an answer?",
        answer:
            "Open a question from the home feed. Scroll down to the answer section "
            "and write your answer in the input field then submit.",
      ),
      FAQItem(
        question: "How to vote on a question or answer?",
        answer:
            "Use the upvote or downvote buttons beside each question "
            "or answer to express whether the content was helpful.",
      ),
      FAQItem(
        question: "How to report a question or answer?",
        answer:
            "Tap the report option available on a question or answer. "
            "Admins will review the report and take necessary action.",
      ),
      FAQItem(
        question: "Where can I see notifications?",
        answer:
            "You can access notifications from the notification icon in the app. "
            "It shows votes, answers to your questions, and other updates.",
      ),
      FAQItem(
        question: "How to search questions by tags?",
        answer:
            "Use the search feature from search screen or filter questions "
            "using tags to find relevant topics quickly.",
      ),
      FAQItem(
        question: "What happens if my account is blocked?",
        answer:
            "You will still be able to login and view questions and answers, "
            "but you will not be able to post questions, answers, or vote.",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : AppColors.lightBackground, 
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// FAQ SECTION
          _sectionTitle(context, "FAQ"),

          _CardContainer(
            children: faqs
                .map(
                  (faq) => _HelpTile(
                    icon: Icons.help_outline,
                    title: faq.question,
                    onTap: () => showHelpBottomSheet(
                      context,
                      icon: Icons.help_outline,
                      title: faq.question,
                      description: faq.answer,
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 28),

          /// OTHER HELP
          _sectionTitle(context, "Other Help"),

          _CardContainer(
            children: [

              _HelpTile(
                icon: Icons.person_outline,
                title: "Contact Developer",
                subtitle: "Reach out to Yash for support",
                onTap: () {
                  showHelpBottomSheet(
                    context,
                    icon: Icons.person_outline,
                    title: 'Contact Developer',
                    description:
                        'Need help or have questions?\n\n'
                        'You can reach out directly to the developer of StackHive.\n\n'
                        'Developer: Yash\n\n'
                        'Feel free to share feedback, report issues, or suggest improvements.',
                  );
                },
              ),

              _HelpTile(
                icon: Icons.bug_report_outlined,
                title: "Report a Bug",
                subtitle: "Found something not working?",
                onTap: () {
                  showHelpBottomSheet(
                    context,
                    icon: Icons.bug_report_outlined,
                    title: 'Report a Bug',
                    description:
                        'If you notice something not working correctly in StackHive, '
                        'please report it.\n\n'
                        'Include details such as what happened and steps to reproduce the issue.',
                  );
                },
              ),

              _HelpTile(
                icon: Icons.lightbulb_outline,
                title: "Request a Feature",
                subtitle: "Suggest improvements for StackHive",
                onTap: () {
                  showHelpBottomSheet(
                    context,
                    icon: Icons.lightbulb_outline,
                    title: 'Request a Feature',
                    description:
                        'Have an idea that could make StackHive better?\n\n'
                        'You can suggest new features or improvements.',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void showHelpBottomSheet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 30),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              SizedBox(height: 24),

              CircleAvatar(
                radius: 34,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 14),

              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),

              // close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Got it', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// FAQ MODEL
class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        child: Row(
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
                icon,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(width: 14),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ]
                ],
              ),
            ),

            Icon(Icons.chevron_right,
              color: theme.colorScheme.outline,
            )
          ],
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final List<Widget> children;

  const _CardContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

Widget _sectionTitle(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 15),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: Theme.of(context)
            .textTheme
            .bodySmall
            ?.color
            ?.withValues(alpha: .7),
      ),
    ),
  );
}

