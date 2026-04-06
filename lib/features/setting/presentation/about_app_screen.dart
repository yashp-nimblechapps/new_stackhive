import 'package:flutter/material.dart';
import 'package:stackhive/core/theme/app_colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const appVersion = '1.0.0';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : AppColors.lightBackground, 
        elevation: 0,
        title:  Text("About App",style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [

            // APP LOGO 
            Center(
              child: Image.asset('assets/images/stackhive_blue.png', width: 150, height: 150)
            ),

            SizedBox(height: 8),

            // APP NAME
            Text("StackHive", style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold )),
            SizedBox(height: 6),

            // TAGLINE
            Text("A community where developers ask, answer, and grow together.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 30),

            /// INFO LIST
            
            _InfoTile(icon: Icons.verified_outlined, title: 'App Version', value: appVersion),
            Divider(height: 1,thickness: 0.6, color: Theme.of(context).dividerColor,),
            
            _InfoTile(icon: Icons.person_outline, title: 'Developer', value: 'Yash'),    
            Divider(height: 1,thickness: 0.6, color: Theme.of(context).dividerColor,),

            _InfoTile(icon: Icons.code, title: 'Built With', value: 'Flutter • Firebase • Riverpod • GoRouter'), 
            Divider(height: 1,thickness: 0.6, color: Theme.of(context).dividerColor,),
            
            _InfoTile(icon: Icons.lightbulb_outline, title: 'Mission', value: 'To help developers share knowledge, solve problems, and grow together through community collaboration.'),         
            
            SizedBox(height: 100),

            /// FOOTER
            Text( 'Made with ❤️ by Yash',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 6),

            Text( "© 2026 StackHive",
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),

    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500),
      ),

      subtitle: Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium
        ),
      ),
    );
  }
}
