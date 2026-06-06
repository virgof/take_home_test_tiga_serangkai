import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minimobile/providers/auth_provider.dart';
import 'package:minimobile/providers/transaction_provider.dart';
import 'package:minimobile/widgets/custom_button.dart';
import 'package:minimobile/widgets/custom_textfield.dart';
import 'package:minimobile/screens/dashboard_screen.dart';
import 'package:minimobile/utils/validators.dart';
import 'package:minimobile/themes/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      // Initialize transaction provider after login
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.fetchDashboard();
      await transactionProvider.fetchTransactions();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Login failed. Please check your credentials.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  'Mini Wallet',
                  textAlign: TextAlign.center,
                  style: AppTheme.headlineLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cardDecoration,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Login',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
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