// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Auth & CRUD',
//       debugShowCheckedModeBanner: false,
//       home: AuthPage(),
//     );
//   }
// }

// class AuthPage extends StatelessWidget {
//   Future<UserCredential> signInWithGoogle() async {
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) {
//       throw Exception('Login dibatalkan');
//     }
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     return await FirebaseAuth.instance.signInWithCredential(credential);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Login / Register")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               child: Text("Login dengan Google"),
//               onPressed: () async {
//                 try {
//                   await signInWithGoogle();
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => NotesPage()),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context)
//                       .showSnackBar(SnackBar(content: Text("Error: $e")));
//                 }
//               },
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               child: Text("Login Email & Password"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => LoginPage()),
//                 );
//               },
//             ),
//             TextButton(
//               child: Text("Belum punya akun? Register"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => RegisterPage()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ================= REGISTER ==================
// class RegisterPage extends StatefulWidget {
//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passController = TextEditingController();

//   Future<void> register() async {
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passController.text.trim(),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => NotesPage()),
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Register")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: "Email"),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: passController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: "Password"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: register,
//               child: Text("Daftar"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ================= LOGIN ==================
// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passController = TextEditingController();

//   Future<void> login() async {
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passController.text.trim(),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => NotesPage()),
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Login Email")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: "Email"),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: passController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: "Password"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: login,
//               child: Text("Login"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ================= NOTES PAGE (CRUD) ==================
// class NotesPage extends StatefulWidget {
//   @override
//   _NotesPageState createState() => _NotesPageState();
// }

// class _NotesPageState extends State<NotesPage> {
//   final TextEditingController _noteController = TextEditingController();
//   final CollectionReference notes =
//       FirebaseFirestore.instance.collection('notes');

//   @override
//   void dispose() {
//     _noteController.dispose();
//     super.dispose();
//   }

//   Future<void> _showEditDialog(DocumentSnapshot doc) async {
//     TextEditingController editController =
//         TextEditingController(text: doc['text']);
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Edit Catatan'),
//         content: TextField(
//           controller: editController,
//           decoration: InputDecoration(hintText: 'Ubah catatan'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Batal', style: TextStyle(color: Colors.red)),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (editController.text.isNotEmpty) {
//                 await notes.doc(doc.id).update({'text': editController.text});
//               }
//               Navigator.pop(context);
//             },
//             child: Text('Simpan'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Catatan"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               await GoogleSignIn().signOut();
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (_) => AuthPage()));
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _noteController,
//               decoration: InputDecoration(
//                 labelText: "Tambah Catatan",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             child: Text("Simpan"),
//             onPressed: () async {
//               if (_noteController.text.trim().isNotEmpty) {
//                 await notes.add({'text': _noteController.text.trim()});
//                 _noteController.clear();
//               }
//             },
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: notes.snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text("Belum ada catatan"));
//                 }
//                 return ListView(
//                   children: snapshot.data!.docs.map((doc) {
//                     return ListTile(
//                       title: Text(doc['text']),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.edit, color: Colors.blue),
//                             onPressed: () => _showEditDialog(doc),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => notes.doc(doc.id).delete(),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/home_page.dart';
import 'package:flutter_application_2/pages/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Contoh',
      debugShowCheckedModeBanner: false,
      home: SignInScreen(),  // langsung arahkan ke HomePage
    );
  }
}
