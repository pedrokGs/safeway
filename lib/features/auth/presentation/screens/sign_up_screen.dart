import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../state/sign_up_state.dart';
import '../widgets/custom_form_text_field.dart';
import '../widgets/submit_form_button.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signUpStateNotifierProvider);
    final notifier = ref.read(signUpStateNotifierProvider.notifier);

    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmaSenhaController = TextEditingController();

    ref.listen<SignUpState>(signUpStateNotifierProvider, (previous, next) {
      if (next.success) {
        context.go('/home');
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    Future<void> signUp() async {
      if (formKey.currentState!.validate()) {
        if(confirmaSenhaController.text.trim() != passwordController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Campos tem que ser iguais")));
          return;
        }
        await notifier.signUp(
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
                controller: emailController,
                labelText: "Email",
                isEnabled: !state.isLoading,
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
                controller: passwordController,
                isPassword: true,
                isEnabled: !state.isLoading,
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
              CustomFormTextField(
                controller: confirmaSenhaController,
                isPassword: true,
                isEnabled: !state.isLoading,
                labelText: "Confirmar Senha",
                icon: Icon(Icons.password),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }

                  if(value != passwordController.text){
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 48),
              SubmitFormButton(
                onPressed: state.isLoading ? null : () async => await signUp(),
                child: state.isLoading ? CircularProgressIndicator() : Text("Cadastrar"),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go("/signIn"),
                child: Text("Já tenho uma conta"),
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