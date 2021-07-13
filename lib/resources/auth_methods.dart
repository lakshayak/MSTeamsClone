import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teams_clone/constants/strings.dart';
import 'package:teams_clone/enum/user_state.dart';
import 'package:teams_clone/models/user.dart';
import 'package:teams_clone/utils/utilities.dart';

// Methods needed for authentication
class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final Firestore firestore = Firestore.instance;
  static final CollectionReference _userCollection = firestore.collection(
      USERS_COLLECTION);

  late StorageReference _storageReference;
  User user = User();

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }

  // Getting details about current user
  Future<User> getUserDetails() async {
    FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
    await _userCollection.document(currentUser.uid).get();

    return User.fromMap(documentSnapshot.data);
  }

  // Getting details about user using unique userID
  Future<User> getUserDetailsById(id) async {
      DocumentSnapshot documentSnapshot =
      await _userCollection.document(id).get();
      return User.fromMap(documentSnapshot.data);
    }

    // To provide Google signin
  Future<FirebaseUser> signIn() async {
    GoogleSignInAccount? _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication = await _signInAccount!
        .authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: _signInAuthentication.idToken,
        accessToken: _signInAuthentication.accessToken);
    final FirebaseUser user = (await _auth.signInWithCredential(credential))
        .user;

    return user;
  }

  // Authentication of user for the 1st time
  Future<bool> authenticateUser(FirebaseUser user) async {
    QuerySnapshot result = await firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;
    return docs.length == 0 ? true : false;
  }

  // Adding user data to firebase database
  Future<void> addDataToDb(FirebaseUser currentUser) async {
    String username = Utils.getUsername(currentUser.email);
    user = User(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoUrl,
        username: username
    );

    var d1 = user.toMap(user);
    Map<String, dynamic> d2 = d1.map((a, b) =>
        MapEntry(a as String, b as dynamic));
    firestore.collection("users")
        .document(currentUser.uid)
        .setData(d2);
  }

  // Signing out of account
  Future<bool> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    }
    catch(e){
      return false;
    }
  }

  // Retrieve all users
  Future<List<User>> fetchAllUsers(FirebaseUser currentUser) async {
    List<User> userList = <User>[];

    QuerySnapshot querySnapshot =
    await firestore.collection("users").getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != currentUser.uid) {
        userList.add(User.fromMap(querySnapshot.documents[i].data));
      }
    }
    return userList;
  }

  // User activity state
  void setUserState({required String userId, required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.document(userId).updateData({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({required String uid}) =>
      _userCollection.document(uid).snapshots();
}
