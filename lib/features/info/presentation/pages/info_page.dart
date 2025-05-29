import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:autoquill_ai/core/theme/design_tokens.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? DesignTokens.darkBackgroundGradient
              : DesignTokens.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, isDarkMode),
              const SizedBox(height: DesignTokens.spaceXL),

              // App Info
              _buildSection(
                context,
                'App Information',
                [
                  _buildInfoRow(context, 'App Name', 'AutoQuill AI'),
                  _buildInfoRow(context, 'Version', '1.0.0'),
                  const SizedBox(height: DesignTokens.spaceSM),
                  Text(
                    'Helpful for users when reporting bugs or checking for updates.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                              : DesignTokens.pureBlack.withValues(alpha: 0.7),
                        ),
                  ),
                ],
                isDarkMode,
              ),

              const SizedBox(height: DesignTokens.spaceLG),

              // Developer Info
              _buildSection(
                context,
                'Developer',
                [
                  _buildInfoRow(context, 'Name', 'Divyansh (Dev) Lalwani'),
                  _buildInfoRow(
                      context, 'Role', 'Undergrad at Johns Hopkins University'),
                  const SizedBox(height: DesignTokens.spaceMD),
                  _buildLinkButton(
                    'Website',
                    'https://dev-lalwani.vercel.app/',
                    Icons.language,
                    DesignTokens.vibrantCoral,
                  ),
                  const SizedBox(height: DesignTokens.spaceXS),
                  _buildLinkButton(
                    'LinkedIn',
                    'https://www.linkedin.com/in/divyansh-lalwani/',
                    Icons.business,
                    DesignTokens.deepBlue,
                  ),
                  const SizedBox(height: DesignTokens.spaceXS),
                  _buildLinkButton(
                    'X (Twitter)',
                    'https://x.com/dsllwn',
                    Icons.alternate_email,
                    DesignTokens.purpleViolet,
                  ),
                ],
                isDarkMode,
              ),

              const SizedBox(height: DesignTokens.spaceLG),

              // Mission
              _buildSection(
                context,
                'Mission',
                [
                  Text(
                    'AutoQuill was built on the belief that voice is our most natural way to communicate—and transcription should be fast, free, and yours.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: isDarkMode
                              ? DesignTokens.trueWhite.withValues(alpha: 0.9)
                              : DesignTokens.pureBlack.withValues(alpha: 0.9),
                        ),
                  ),
                ],
                isDarkMode,
              ),

              const SizedBox(height: DesignTokens.spaceLG),

              // Acknowledgments
              _buildSection(
                context,
                'Acknowledgments',
                [
                  _buildAcknowledgment(context, 'Groq',
                      'for fast, free and secure Whisper inference'),
                  _buildAcknowledgment(context, 'Zapsplat', 'for sound assets'),
                  _buildAcknowledgment(
                      context, 'Flutter', 'for the cross-platform framework'),
                ],
                isDarkMode,
              ),

              const SizedBox(height: DesignTokens.spaceLG),

              // Licensing
              _buildSection(
                context,
                'Licensing',
                [
                  Row(
                    children: [
                      Icon(
                        Icons.gavel,
                        size: DesignTokens.iconSizeSM,
                        color: DesignTokens.vibrantCoral,
                      ),
                      const SizedBox(width: DesignTokens.spaceXS),
                      Text(
                        'MIT License',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: DesignTokens.fontWeightSemiBold,
                              color: DesignTokens.vibrantCoral,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceSM),
                  Text(
                    'This project is open source and available under the MIT License. See the LICENSE file for more details.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? DesignTokens.trueWhite.withValues(alpha: 0.8)
                              : DesignTokens.pureBlack.withValues(alpha: 0.8),
                        ),
                  ),
                ],
                isDarkMode,
              ),

              const SizedBox(height: DesignTokens.spaceLG),

              // Privacy & Data Policy
              _buildSection(
                context,
                'Privacy & Data Policy',
                [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        size: DesignTokens.iconSizeSM,
                        color: DesignTokens.emeraldGreen,
                      ),
                      const SizedBox(width: DesignTokens.spaceXS),
                      Text(
                        'Your Privacy Matters',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: DesignTokens.fontWeightSemiBold,
                              color: DesignTokens.emeraldGreen,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceSM),
                  Text(
                    'AutoQuill does not collect or store any user data. All voice processing happens securely through Groq\'s API.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? DesignTokens.trueWhite.withValues(alpha: 0.8)
                              : DesignTokens.pureBlack.withValues(alpha: 0.8),
                        ),
                  ),
                ],
                isDarkMode,
              ),

              const SizedBox(height: DesignTokens.spaceLG),

              // Support
              _buildSection(
                context,
                'Support & Links',
                [
                  const SizedBox(height: DesignTokens.spaceXS),
                  _buildLinkButton(
                    'GitHub Repository',
                    'https://github.com/DevelopedByDev/autoquill_ai',
                    Icons.code,
                    DesignTokens.purpleViolet,
                  ),
                ],
                isDarkMode,
              ),

              const SizedBox(height: DesignTokens.spaceXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLG),
      decoration: BoxDecoration(
        gradient: DesignTokens.coralGradient,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.vibrantCoral.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceSM),
            decoration: BoxDecoration(
              color: DesignTokens.trueWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            ),
            child: Icon(
              Icons.info_outline,
              size: DesignTokens.iconSizeLG,
              color: DesignTokens.trueWhite,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About AutoQuill',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: DesignTokens.trueWhite,
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                ),
                const SizedBox(height: DesignTokens.spaceXXS),
                Text(
                  'Your fast, free and secure transcription companion',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DesignTokens.trueWhite.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title,
      List<Widget> children, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLG),
      decoration: BoxDecoration(
        color: isDarkMode
            ? DesignTokens.darkSurfaceElevated.withValues(alpha: 0.8)
            : DesignTokens.trueWhite.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        boxShadow:
            isDarkMode ? DesignTokens.cardShadowDark : DesignTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: DesignTokens.fontWeightSemiBold,
                  color: isDarkMode
                      ? DesignTokens.trueWhite
                      : DesignTokens.pureBlack,
                ),
          ),
          const SizedBox(height: DesignTokens.spaceMD),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: DesignTokens.fontWeightMedium,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: DesignTokens.fontWeightSemiBold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgment(
      BuildContext context, String name, String description) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceXS),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: DesignTokens.iconSizeSM,
            color: DesignTokens.emeraldGreen,
          ),
          const SizedBox(width: DesignTokens.spaceXS),
          Text(
            name,
            style: TextStyle(
              fontWeight: DesignTokens.fontWeightSemiBold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceXS),
          Expanded(
            child: Text(
              '– $description',
              style: TextStyle(
                color: isDarkMode
                    ? DesignTokens.trueWhite.withValues(alpha: 0.7)
                    : DesignTokens.pureBlack.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(
      String label, String url, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: Icon(icon, size: DesignTokens.iconSizeSM),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceMD,
            vertical: DesignTokens.spaceSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
