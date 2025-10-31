import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safeway/core/configs/route_paths.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../state/sign_in_state.dart';
import '../widgets/custom_form_text_field.dart';
import '../widgets/submit_form_button.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInStateNotifierProvider);
    final notifier = ref.read(signInStateNotifierProvider.notifier);

    final formKey = GlobalKey<FormState>();

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen<SignInState>(signInStateNotifierProvider, (previous, next) {
      if (next.success) {
        context.go(RoutePaths.home);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    Future<void> signIn() async {
      if (formKey.currentState!.validate()) {
        await notifier.signIn(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      }
    }

    Future<void> signInWithGoogle() async {
      await notifier.signInWithGoogle();
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomFormTextField(
                isEnabled: !state.isLoading,
                controller: emailController,
                labelText: "Email",
                icon: Icon(Icons.email),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value.trim())) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 48),
              CustomFormTextField(
                isEnabled: !state.isLoading,
                controller: passwordController,
                isPassword: true,
                labelText: "Senha",
                icon: Icon(Icons.password),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (value.trim().length < 6) {
                    return 'Senha muito curta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),
              SubmitFormButton(
                onPressed: state.isLoading ? null : () async => await signIn(),
                child: state.isLoading
                    ? CircularProgressIndicator()
                    : Text("Entrar"),
              ),
              TextButton(
                onPressed: () => context.go(RoutePaths.resetPassword),
                child: Text("Esqueci minha senha"),
              ),
              TextButton(
                onPressed: () => context.go(RoutePaths.signUp),
                child: Text("Não possuo uma conta"),
              ),

              SignInButton(
                Buttons.google,
                onPressed: signInWithGoogle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                text: "Entrar com Google",
                padding: EdgeInsets.all(4.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
