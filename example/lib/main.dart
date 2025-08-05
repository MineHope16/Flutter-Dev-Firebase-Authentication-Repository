import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_auth_repository/flutter_firebase_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Repository Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = FirebaseAuthRepository();

    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return HomePage(authRepository: authRepository);
        } else {
          return LoginPage(authRepository: authRepository);
        }
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  final FirebaseAuthRepository authRepository;

  const LoginPage({super.key, required this.authRepository});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _resetEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await widget.authRepository.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
        _showSnackBar('Account created successfully!', Colors.green);
      } else {
        await widget.authRepository.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        _showSnackBar('Signed in successfully!', Colors.green);
      }
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // Replace with your actual Google server client ID
      const serverClientId = 'YOUR_GOOGLE_SERVER_CLIENT_ID';
      await widget.authRepository.signInWithGoogle(serverClientId: serverClientId);
      _showSnackBar('Google sign-in successful!', Colors.green);
    } catch (e) {
      _showSnackBar('Google sign-in failed: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _isLoading = true);

    try {
      await widget.authRepository.signInWithFacebook();
      _showSnackBar('Facebook sign-in successful!', Colors.green);
    } catch (e) {
      _showSnackBar('Facebook sign-in failed: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGitHubSignIn() async {
    setState(() => _isLoading = true);

    try {
      await widget.authRepository.signInWithGitHub();
      _showSnackBar('GitHub sign-in successful!', Colors.green);
    } catch (e) {
      _showSnackBar('GitHub sign-in failed: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMicrosoftSignIn() async {
    setState(() => _isLoading = true);

    try {
      await widget.authRepository.signInWithMicrosoft();
      _showSnackBar('Microsoft sign-in successful!', Colors.green);
    } catch (e) {
      _showSnackBar('Microsoft sign-in failed: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePasswordReset() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: _resetEmailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _resetEmailController.text),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (email != null && email.isNotEmpty) {
      try {
        await widget.authRepository.resetPassword(email: email.trim());
        _showSnackBar('Password reset email sent!', Colors.green);
      } catch (e) {
        _showSnackBar('Failed to send reset email: ${e.toString()}', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.local_fire_department,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'Firebase Auth Repository',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Name field (only for sign up)
              if (_isSignUp) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Sign In/Up Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleEmailAuth,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
              ),
              const SizedBox(height: 16),

              // Toggle Sign In/Up
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : "Don't have an account? Sign Up",
                ),
              ),

              // Password Reset
              if (!_isSignUp)
                TextButton(
                  onPressed: _handlePasswordReset,
                  child: const Text('Forgot Password?'),
                ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // Social Sign-In Buttons
              const Text(
                'Or continue with:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              _SocialSignInButton(
                onPressed: _handleGoogleSignIn,
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                color: Colors.red,
              ),
              const SizedBox(height: 12),

              _SocialSignInButton(
                onPressed: _handleFacebookSignIn,
                icon: Icons.facebook,
                label: 'Continue with Facebook',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              _SocialSignInButton(
                onPressed: _handleGitHubSignIn,
                icon: Icons.code,
                label: 'Continue with GitHub',
                color: Colors.black,
              ),
              const SizedBox(height: 12),

              _SocialSignInButton(
                onPressed: _handleMicrosoftSignIn,
                icon: Icons.business,
                label: 'Continue with Microsoft',
                color: Colors.blue[800]!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _SocialSignInButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final FirebaseAuthRepository authRepository;

  const HomePage({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await authRepository.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed out successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to sign out: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'UID:',
                      value: user?.uid ?? 'N/A',
                    ),
                    _InfoRow(
                      label: 'Email:',
                      value: user?.email ?? 'N/A',
                    ),
                    _InfoRow(
                      label: 'Display Name:',
                      value: user?.displayName ?? 'N/A',
                    ),
                    _InfoRow(
                      label: 'Email Verified:',
                      value: user?.emailVerified.toString() ?? 'N/A',
                    ),
                    _InfoRow(
                      label: 'Created:',
                      value: user?.metadata.creationTime?.toString() ?? 'N/A',
                    ),
                    _InfoRow(
                      label: 'Last Sign In:',
                      value: user?.metadata.lastSignInTime?.toString() ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features Demonstrated',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('✅ Email/Password Authentication'),
                    Text('✅ Google Sign-In'),
                    Text('✅ Facebook Sign-In'),
                    Text('✅ GitHub Sign-In'),
                    Text('✅ Microsoft Sign-In'),
                    Text('✅ Password Reset'),
                    Text('✅ Real-time Auth State Listening'),
                    Text('✅ Automatic Firestore User Document Creation'),
                    Text('✅ Comprehensive Error Handling'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
