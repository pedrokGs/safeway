import 'package:safeway/features/auth/presentation/state/sign_up_state.dart';

class TestSignUpNotifier extends SignUpStateNotifier {
  TestSignUpNotifier() : super();
  String? lastEmail;
  String? lastPassword;

  bool googleSignUpCalled = false;

  @override
  SignUpState build() => const SignUpState();

  void setState(SignUpState newState) {
    state = newState;
  }

  @override
  Future<void> signUp(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    setState(const SignUpState(success: true));
  }

  @override
  Future<void> signInWithGoogle() async {
    googleSignUpCalled = true;
    setState(const SignUpState(success: true));
  }
}
