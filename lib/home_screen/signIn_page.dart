import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData =
      await _firestore.collection('users').doc(user.uid).get();

      if (userData.exists) {
        setState(() {
          _nameController.text = userData['name'];
          _lastNameController.text = userData['lastName'];
          _middleNameController.text = userData['middleName'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTextFormField(context, 'Имя', _nameController),
          _buildTextFormField(context, 'Фамилия', _lastNameController),
          _buildTextFormField(context, 'Отчество', _middleNameController),
          ElevatedButton(
              onPressed: () async {
                await _signInAndSaveData();
                if (mounted) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
                }
              },
              child: Text('Войти'))
        ],
      ),
    );
  }

  Future<void> _signInAndSaveData() async {
    UserCredential userCredential = await _auth.signInAnonymously();
    User? user = userCredential.user;
    await _firestore.collection('users').doc(user?.uid).set({
      'name': _nameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'middleName': _middleNameController.text.trim(),
    });
  }

  Widget _buildTextFormField(BuildContext context, String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFEDF2F6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: controller,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: title,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9DB7CB),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
