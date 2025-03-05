import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  bool obscureText = true;

  void toggleObscureText() {
    obscureText = !obscureText;
    emit(IconPassword()); // Update UI
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(SignUpLoading());
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      emit(SignUpFailure(
          errMessage: 'Please enter Name and Email and Password.'));

    } else {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        emit(SignUpSuccess());
        FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user?.uid)
            .set({
          'name': name,
          'last conversation': [],
        });
        await credential.user?.sendEmailVerification();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          emit(SignUpFailure(errMessage: 'The password provided is too weak.'));
        } else if (e.code == 'email-already-in-use') {
          emit(SignUpFailure(
              errMessage: 'The account already exists for that email.'));
        }
      } catch (e) {
        emit(SignUpFailure(
            errMessage: 'Something went wrong. Please try again.'));
      }
    }
  }
}
