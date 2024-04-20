import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String userId; // Assuming you have a way to get the user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            var data = snapshot.data!;
            String name = data['name'];
            String email = data['email'];
            String phone = data['phone'];
            String profilePicUrl = data['profile_pic_url'];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl) : null,
                    child: profilePicUrl == null ? Image.asset('assets/profile_pic.jpg') : null,
                  ),
                  SizedBox(height: 20),
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'UserID: $userId',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: $email',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Phone: $phone',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage(userId: userId)),
                      );
                    },
                    child: Text('Edit Profile'),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text('Error fetching profile data'));
        },
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String userId;

  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _profilePic;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    // Fetch existing profile data if available
    fetchProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> fetchProfileData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (snapshot.exists) {
      setState(() {
        _nameController.text = snapshot['name'];
        _emailController.text = snapshot['email'];
        _phoneController.text = snapshot['phone'];
      });
    }
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      setState(() {
        _profilePic = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;

    // Upload profile picture to Firebase Storage
    if (_profilePic != null) {
      String fileName = 'profile_pic_${DateTime.now().millisecondsSinceEpoch}.jpg';
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
      await ref.putFile(_profilePic!);
      String profilePicUrl = await ref.getDownloadURL();

      // Update profile with profile picture URL
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'profile_pic_url': profilePicUrl,
      });
    } else {
      // Update profile without profile picture
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'name': name,
        'email': email,
        'phone': phone,
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profilePic != null ? FileImage(_profilePic!) : null,
              child: _profilePic == null ? Image.asset('assets/profile_pic.jpg') : null,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Profile Picture'),
            ),
            SizedBox(height: 20),
            Text(
              'Name',
              style: TextStyle(fontSize: 16),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Email',
              style: TextStyle(fontSize: 16),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Phone',
              style: TextStyle(fontSize: 16),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
