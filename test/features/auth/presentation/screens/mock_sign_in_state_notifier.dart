import 'package:safeway/features/auth/presentation/state/sign_in_state.dart';

class TestSignInNotifier extends SignInStateNotifier {
  TestSignInNotifier() : super();
  String? lastEmail;
  String? lastPassword;

  bool googleSignInCalled = false;

  @override
  SignInState build() => const SignInState();

  void setState(SignInState newState) {
    state = newState;
  }

  @override
  Future<void> signIn(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    setState(const SignInState(success: true));
  }

  @override
  Future<void> signInWithGoogle() async {
    googleSignInCalled = true;
    setState(const SignInState(success: true));
  }
}
