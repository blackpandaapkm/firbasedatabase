import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}
File? _profilePic;
class ProfilePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              // Use the Image.file widget to display the image from the file system
              backgroundImage: _profilePic != null ? FileImage(_profilePic!) : null,
              // If there's no profile picture, you can display a placeholder asset
              child: _profilePic == null ? Image.asset('assets/profile_pic.jpg') : null,
            ),
            SizedBox(height: 20),
            Text(
              'John Doe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'UserID: john_doe123',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Gender: Male',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Email: john.doe@example.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: +1234567890',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
              child: Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}


void _loadProfilePicture() async {
  // You can load a default profile picture from assets if needed
  // For example:
  // setState(() {
  //   _profilePic = await rootBundle.loadString('assets/profile_pic.jpg');
  // });
}


class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Define TextEditingController for each field
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  // Placeholder image URL for demonstration
  // File? _profilePic;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  void initState() {
    super.initState();
    // Load the default profile picture from assets
    _loadProfilePicture();
  }

  void _loadProfilePicture() async {
    // You can load a default profile picture from assets if needed
    // For example:
    // setState(() {
    //   _profilePic = await rootBundle.loadString('assets/profile_pic.jpg');
    // });
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Update the profile picture using setState
      setState(() {
        _profilePic = File(pickedFile.path);
      });
    }
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
              // Use the Image.file widget to display the image from the file system
              backgroundImage: _profilePic != null ? FileImage(_profilePic!) : null,
              // If there's no profile picture, you can display a placeholder asset
              child: _profilePic == null ? Image.asset('assets/profile_pic.jpg') : null,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload'),
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
              onPressed: () {
                // Update profile information
                // Example: Save the changes to a database
                // For now, let's just print the updated information
                print('Name: ${_nameController.text}');
                print('Email: ${_emailController.text}');
                print('Phone: ${_phoneController.text}');
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
