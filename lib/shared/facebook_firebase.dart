import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<UserCredential?> signInWithFacebook() async {
  // Trigger the sign-in flow
  final LoginResult loginResult = await FacebookAuth.instance.login();

  // Create a credential from the access token
  if (loginResult.status == LoginStatus.success) {
    final AccessToken accessToken = loginResult.accessToken!;
    final OAuthCredential credential =
        FacebookAuthProvider.credential(accessToken.tokenString);

    try {
      // Sign in with Firebase using the credential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication exceptions
      print('FirebaseAuthException: ${e.message}');
      return null;
    } catch (e) {
      // Handle other exceptions
      print('Exception: $e');
      return null;
    }
  } else {
    // login was not successful, for example user cancelled the process
    print('Facebook login failed: ${loginResult.status}');
    return null;
  }
}

void logoutFacebook() async {
  // Log out from Facebook
  await FacebookAuth.instance.logOut();
  // Optionally log out from Firebase
  await FirebaseAuth.instance.signOut();
}
