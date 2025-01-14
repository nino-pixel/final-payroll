import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  bool _isLoading = true;
  Map<String, dynamic> _profile = {};
  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);
      final profile = await _profileService.getProfile();
      setState(() {
        _profile = profile;
        _initializeControllers();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load profile')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    _controllers = {
      'first_name': TextEditingController(text: _profile['first_name']),
      'last_name': TextEditingController(text: _profile['last_name']),
      'email': TextEditingController(text: _profile['email']),
      'phone': TextEditingController(text: _profile['phone']),
      'address': TextEditingController(text: _profile['address']),
    };
  }

  Future<void> _submitUpdateRequest() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final changes = {};
      _controllers.forEach((field, controller) {
        if (controller.text != _profile[field]) {
          changes[field] = controller.text;
        }
      });

      if (changes.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No changes to submit')));
        return;
      }

      await _profileService.requestUpdate(changes);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update request submitted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit update request')));
    }
  }

  Future<void> _updateProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      await _profileService.uploadProfilePicture(image.path);
      await _loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: _updateProfilePicture,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _profile['profile_picture'] != null
                    ? NetworkImage(_profile['profile_picture'])
                    : null,
                child: _profile['profile_picture'] == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _controllers['first_name'],
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                focusNode: FocusNode(),
              ),
              TextFormField(
                controller: _controllers['last_name'],
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                focusNode: FocusNode(),
              ),
              TextFormField(
                controller: _controllers['email'],
                decoration: InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                focusNode: FocusNode(),
              ),
              TextFormField(
                controller: _controllers['phone'],
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                focusNode: FocusNode(),
              ),
              TextFormField(
                controller: _controllers['address'],
                decoration: InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                focusNode: FocusNode(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitUpdateRequest,
                child: Text('Submit Update Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
