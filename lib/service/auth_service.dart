import 'package:firebase_auth/firebase_auth.dart';
import 'package:itum_communication_platform/helper/helper_function.dart';
import 'package:itum_communication_platform/service/database_service.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future loginWithUserNameandPassword(String email, String password)async{
    try{

      User user =(await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password)).user!;

      if(user!=null){
        return true;
      }

    } on FirebaseAuthException catch (e){
      return e.message;
    }
  }

  Future registerUserWithEmailandPassword(String fullName, String email, String password)async{
    try{

      User user =(await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password)).user!;

      if(user!=null){

        await DatabaseService(uid: user.uid).savingUserData(fullName, email);
        return true;
      }

    } on FirebaseAuthException catch (e){
      return e.message;
    }
  }

  Future signOut() async{
    try{
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      await firebaseAuth.signOut();

    } catch(e){
      return null;
    }
  }
}