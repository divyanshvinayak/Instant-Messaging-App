import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:express/providers/app.dart';
import 'package:express/screens/home_screen.dart';
import 'package:express/widgets/bottom_sheet_icon.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String phone;

  const ProfileSetupScreen({required this.phone});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    alignment: Alignment.center,
                    child: const Text(
                      'Set up your profile',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          height: 1.25),
                    ),
                  ),
                  GestureDetector(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.expand,
                        children: [
                          _image == null
                              ? CircleAvatar(
                                  maxRadius: 50,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: Colors.black87,
                                    size: 50,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      Image.file(File(_image!.path)).image,
                                  maxRadius: 50,
                                ),
                          Positioned(
                            bottom: -5,
                            right: -27,
                            child: RawMaterialButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _showBottomSheet();
                              },
                              elevation: 2.0,
                              fillColor: Colors.grey[100],
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.black87,
                              ),
                              padding: const EdgeInsets.all(6),
                              shape: const CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      _showBottomSheet();
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: 15, right: 15, bottom: 10, top: 30),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: TextField(
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'First name (required)',
                        hintStyle: const TextStyle(color: Colors.black38),
                      ),
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 40),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: TextField(
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Last name (optional)',
                        hintStyle: const TextStyle(color: Colors.black38),
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 60,
                    margin: MediaQuery.of(context).viewInsets.bottom == 0
                        ? const EdgeInsets.only(bottom: 60)
                        : const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _registerUser();
                        },
                        child: const Text('NEXT')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) => _bottomSheet(),
    );
  }

  Widget _bottomSheet() {
    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  const Text(
                    'Profile photo',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _image != null
                      ? BottomSheetIcon(
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                          text: 'Remove\nphoto',
                          radius: 25,
                          function: () {
                            setState(() {
                              _image = null;
                              Navigator.of(context).pop();
                            });
                          },
                        )
                      : Container(),
                  _image != null
                      ? const SizedBox(
                          width: 40,
                        )
                      : Container(),
                  BottomSheetIcon(
                    icon: Icons.photo,
                    backgroundColor: Colors.purple,
                    text: 'Gallery\n',
                    radius: 25,
                    function: () {
                      _onImageButtonPressed(ImageSource.gallery,
                          context: context);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  BottomSheetIcon(
                    icon: Icons.camera_alt,
                    backgroundColor: Colors.pink,
                    text: 'Camera\n',
                    radius: 25,
                    function: () {
                      _onImageButtonPressed(ImageSource.camera,
                          context: context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      final SnackBar snackBar = SnackBar(content: Text('$e'));
      ScaffoldMessenger.of(context!).showSnackBar(snackBar);
    }
  }

  Future<void> _registerUser() async {
    if (_firstNameController.text.trim().isNotEmpty) {
      await Provider.of<App>(context, listen: false).login(widget.phone,
          _firstNameController.text + ' ' + _lastNameController.text, _image);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (builder) => HomeScreen(),
        ),
      );
    } else {
      const SnackBar snackBar =
          SnackBar(content: Text('First name is required and cannot be empty'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
