import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth_repository/firebase_auth_repository.dart';

/// A widget that provides social sign-in buttons
class SocialSignInButtons extends StatefulWidget {
  final FirebaseAuthRepository authRepository;

  const SocialSignInButtons({super.key, required this.authRepository});

  @override
  State<SocialSignInButtons> createState() => _SocialSignInButtonsState();
}

class _SocialSignInButtonsState extends State<SocialSignInButtons> {
  bool _isLoading = false;
  String? _loadingProvider;

  Future<void> _handleGoogleSignIn() async {
    await _handleSocialSignIn('google', () async {
      // Replace with your actual Google server client ID
      const serverClientId = 'YOUR_GOOGLE_SERVER_CLIENT_ID';
      await widget.authRepository.signInWithGoogle(
        serverClientId: serverClientId,
      );
    });
  }

  Future<void> _handleFacebookSignIn() async {
    await _handleSocialSignIn('facebook', () async {
      await widget.authRepository.signInWithFacebook();
    });
  }

  Future<void> _handleGitHubSignIn() async {
    await _handleSocialSignIn('github', () async {
      await widget.authRepository.signInWithGitHub();
    });
  }

  Future<void> _handleMicrosoftSignIn() async {
    await _handleSocialSignIn('microsoft', () async {
      await widget.authRepository.signInWithMicrosoft();
    });
  }

  Future<void> _handleSocialSignIn(
    String provider,
    Future<void> Function() signInMethod,
  ) async {
    setState(() {
      _isLoading = true;
      _loadingProvider = provider;
    });

    try {
      await signInMethod();
      _showSnackBar(
        '${_capitalizeFirst(provider)} sign-in successful!',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar(
        '${_capitalizeFirst(provider)} sign-in failed: ${e.toString()}',
        Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
        _loadingProvider = null;
      });
    }
  }

  String _capitalizeFirst(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Or continue with:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        _SocialSignInButton(
          onPressed: _isLoading ? null : _handleGoogleSignIn,
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          color: Colors.red,
          isLoading: _loadingProvider == 'google',
        ),
        const SizedBox(height: 12),

        _SocialSignInButton(
          onPressed: _isLoading ? null : _handleFacebookSignIn,
          icon: Icons.facebook,
          label: 'Continue with Facebook',
          color: Colors.blue,
          isLoading: _loadingProvider == 'facebook',
        ),
        const SizedBox(height: 12),

        _SocialSignInButton(
          onPressed: _isLoading ? null : _handleGitHubSignIn,
          icon: Icons.code,
          label: 'Continue with GitHub',
          color: Colors.black,
          isLoading: _loadingProvider == 'github',
        ),
        const SizedBox(height: 12),

        _SocialSignInButton(
          onPressed: _isLoading ? null : _handleMicrosoftSignIn,
          icon: Icons.business,
          label: 'Continue with Microsoft',
          color: Colors.blue[800]!,
          isLoading: _loadingProvider == 'microsoft',
        ),
      ],
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;

  const _SocialSignInButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color),
      ),
    );
  }
}
