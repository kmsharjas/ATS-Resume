import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../providers/resume_provider.dart';
import '../../models/resume_model.dart';

class ContactInfoStep extends StatefulWidget {
  const ContactInfoStep({super.key});

  @override
  State<ContactInfoStep> createState() => _ContactInfoStepState();
}

class _ContactInfoStepState extends State<ContactInfoStep> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _linkedinController;
  late TextEditingController _portfolioController;
  String? _photoBase64;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    final contactInfo = context.read<ResumeProvider>().resume.contactInfo;
    _fullNameController = TextEditingController(text: contactInfo.fullName);
    _emailController = TextEditingController(text: contactInfo.email);
    _phoneController = TextEditingController(text: contactInfo.phone);
    _locationController = TextEditingController(text: contactInfo.location);
    _linkedinController =
        TextEditingController(text: contactInfo.linkedinUrl ?? '');
    _portfolioController =
        TextEditingController(text: contactInfo.portfolioUrl ?? '');
    _photoBase64 = contactInfo.profilePhotoPath;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _photoBytes = bytes;
          _photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          _updateContactInfo();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery);

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _photoBytes = bytes;
          _photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
          _updateContactInfo();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _photoBase64 = null;
      _photoBytes = null;
      _updateContactInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your contact details will be prominently displayed at the top of your resume.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            // Photo Upload Section
            _buildPhotoSection(context),
            const SizedBox(height: 32),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'John Doe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _updateContactInfo();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'john@example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                _updateContactInfo();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: '+1 (555) 123-4567',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                _updateContactInfo();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location *',
                hintText: 'San Francisco, CA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _updateContactInfo();
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Optional Links',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _linkedinController,
              decoration: InputDecoration(
                labelText: 'LinkedIn URL',
                hintText: 'linkedin.com/in/johndoe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _updateContactInfo();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portfolioController,
              decoration: InputDecoration(
                labelText: 'Portfolio/Website URL',
                hintText: 'johndoe.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _updateContactInfo();
              },
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pro Tip: Use standard formatting for phone numbers and ensure your email is professional.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Photo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (_photoBase64 != null && _photoBytes != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _photoBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.edit),
                    label: const Text('Change Photo'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _removePhoto,
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove'),
                  ),
                ],
              ),
            ],
          )
        else
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Click to upload photo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Optional - Professional headshot recommended',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _updateContactInfo() {
    context.read<ResumeProvider>().updateContactInfo(
          ContactInfo(
            fullName: _fullNameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            location: _locationController.text,
            linkedinUrl: _linkedinController.text.isEmpty
                ? null
                : _linkedinController.text,
            portfolioUrl: _portfolioController.text.isEmpty
                ? null
                : _portfolioController.text,
            profilePhotoPath: _photoBase64,
          ),
        );
  }
}
