// pubspec.yaml dependencies
/*
dependencies:
  image_picker: ^1.0.7
  cloudinary_public: ^0.21.0
  firebase_database: ^10.4.0
  firebase_core: ^2.24.2
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class ProductUpload extends StatefulWidget {
  @override
  _ProductUploadState createState() => _ProductUploadState();
}

class _ProductUploadState extends State<ProductUpload> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;
  
  // Form fields
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Initialize Cloudinary
  final cloudinary = CloudinaryPublic(
    'your-cloud-name',  // Replace with your cloud name
    'your-upload-preset',  // Replace with your upload preset
    cache: false,
  );

  // Initialize Firebase
  final databaseRef = FirebaseDatabase.instance.ref().child('products');

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<String?> _uploadToCloudinary() async {
    if (_imageFile == null) return null;

    try {
      CloudinaryResponse response;
      
      if (kIsWeb) {
        // For web platform
        final bytes = await _imageFile!.readAsBytes();
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromBytes(
            bytes,
            folder: 'products',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      } else {
        // For mobile platform
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _imageFile!.path,
            folder: 'products',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      }
      
      return response.secureUrl;
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image to Cloudinary
      _imageUrl = await _uploadToCloudinary();
      
      if (_imageUrl == null) throw Exception('Failed to upload image');

      // Save to Firebase
      await databaseRef.push().set({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'imageUrl': _imageUrl,
        'createdAt': ServerValue.timestamp,
      });

      // Clear form
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _imageFile = null;
        _imageUrl = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading product: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
              if (_imageFile != null) ...[
                kIsWeb
                    ? Image.network(_imageFile!.path, height: 200)
                    : Image.file(File(_imageFile!.path), height: 200),
                SizedBox(height: 16),
              ],

              // Image picker buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Camera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library),
                    label: Text('Gallery'),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Product details form
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter product name' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter price' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Upload Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}