import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/local_auth_service.dart';
import '../../services/pin_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/snack.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await AuthService.instance.signInWithEmailPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      final uid = cred.user!.uid;
      await FirestoreService.instance.updateUserLastLogin(
        userId: uid,
        lastLogin: Timestamp.now(),
      );
      await FirestoreService.instance.addLoginHistory(uid);

      final shouldSetup = await _askSetupPin();
      if (shouldSetup == true && mounted) {
        await _setupPinFlow();
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnack(context, 'Login failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool?> _askSetupPin() async {
    final existing = await PinService.instance.getPin();
    if (existing != null && existing.isNotEmpty) return false;
    if (!mounted) return false;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable PIN login?'),
        content: const Text(
          'This lets you unlock the app faster on this device. '
          'Email/password is still supported.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enable')),
        ],
      ),
    );
  }

  Future<void> _setupPinFlow() async {
    final pin = await _promptForPin(title: 'Set a 4-digit PIN');
    if (pin == null) return;
    final confirm = await _promptForPin(title: 'Confirm PIN');
    if (confirm == null) return;
    if (pin != confirm) {
      if (mounted) showSnack(context, 'PINs do not match');
      return;
    }
    await PinService.instance.setPin(pin);
    if (mounted) showSnack(context, 'PIN enabled');
  }

  Future<String?> _promptForPin({required String title}) async {
    final ctrl = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'PIN',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final v = ctrl.text.trim();
                if (!RegExp(r'^\d{4}$').hasMatch(v)) return;
                Navigator.pop(context, v);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> _unlockWithBiometricOrPin() async {
    final current = AuthService.instance.currentUser;
    if (current == null) {
      if (!mounted) return;
      showSnack(context, 'First login with email & password once.');
      return;
    }

    final canBio = await LocalAuthService.instance.canCheckBiometrics();
    bool unlocked = false;
    if (canBio) {
      unlocked = await LocalAuthService.instance.authenticate(
        reason: 'Unlock Echo Diary App',
      );
    }

    if (!unlocked) {
      final savedPin = await PinService.instance.getPin();
      if (savedPin == null) {
        if (!mounted) return;
        showSnack(context, 'No PIN set on this device.');
        return;
      }
      final entered = await _promptForPin(title: 'Enter PIN to unlock');
      unlocked = entered == savedPin;
    }

    if (!mounted) return;
    if (unlocked) {
      Navigator.of(context).pop();
    } else {
      showSnack(context, 'Unlock failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Enter email';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                  onFieldSubmitted: (_) => _login(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Login',
                  icon: Icons.login,
                  isLoading: _loading,
                  onPressed: _login,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _unlockWithBiometricOrPin,
                  icon: const Icon(Icons.fingerprint),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Biometric / PIN Unlock'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

