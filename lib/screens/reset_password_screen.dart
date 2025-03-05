import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:outdoor_navigation/services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Inserisci la nuova password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Nuova Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (!mounted) return; // Controllo PRIMA di aggiornare lo stato

                      setState(() => _isLoading = true);
                      String? message;
                      bool success = false;

                      try {
                        await authService.completePasswordReset(
                          newPassword: _passwordController.text,
                        );
                        message = "Password aggiornata con successo!";
                        success = true;
                      } catch (e) {
                        message = "Errore: ${e.toString()}";
                      }

                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });

                        // Usare `addPostFrameCallback` per eseguire il codice dopo il frame
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message!),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          if (success) {
                            Navigator.pushReplacementNamed(context, "/login");
                          }
                        });
                      }
                    },
                    child: const Text("Conferma"),
                  ),
          ],
        ),
      ),
    );
  }
}
