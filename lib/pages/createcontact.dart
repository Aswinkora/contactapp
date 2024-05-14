import 'dart:io';
import 'package:email_validator/email_validator.dart';

import 'package:contact/Data/database.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<StatefulWidget> createState() {
    return AddContactState();
  }
}

class AddContactState extends State<AddContact> {
  TextEditingController namecntrl = TextEditingController();
  TextEditingController phncntrl = TextEditingController();
  TextEditingController emailcntrl = TextEditingController();
  File? image;
  Future<void> getimage() async {
    final picker = ImagePicker();
    final pickedfile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedfile == null) return;
    setState(() {
      image = File(pickedfile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: IconButton(
          icon: const Icon(Icons.cancel_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text('create Contact'),
        actions: [
          TextButton(
            onPressed: () {
              saveContact();
            },
            child: const Text(
              'SAVE',
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      getimage();
                    },
                    child: CircleAvatar(
                      radius: 64,
                      backgroundImage: (image == null)
                          ? const AssetImage('images/avatar.png')
                          : FileImage(image!) as ImageProvider,
                    ),
                  ),
                ),
                const Gap(20),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: namecntrl,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person), labelText: 'Name'),
                ),
                const Gap(20),
                TextFormField(
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: phonevalidation,
                  controller: phncntrl,
                  decoration: const InputDecoration(
                      counterText: '',
                      prefixIcon: Icon(Icons.phone_android),
                      labelText: 'Phone'),
                ),
                const Gap(20),
                TextFormField(
                  validator: emailvalidate,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: emailcntrl,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_rounded),
                      labelText: 'Email'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void saveContact() {
    if (namecntrl.text.isEmpty ||
        phncntrl.text.isEmpty ||
        emailcntrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pleasefill All the fields')));
    } else if (phonevalidation(phncntrl.text) != null ||
        emailvalidate(emailcntrl.text) != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Some error occured')));
    } else {
      String name = namecntrl.text;
      int phone = int.tryParse(phncntrl.text) ?? 0;
      String email = emailcntrl.text;
      Contact newcontact = Contact(name: name, phone: phone, email: email);
      SqlStorage().insert(newcontact);
      setState(() {});
      Navigator.pop(context, newcontact);
    }
  }

  String? phonevalidation(value) {
    if (value.isEmpty) {
      return null;
    }
    if (value.length < 10) {
      return 'Enter the full number';
    }
    return null;
  }

  String? emailvalidate(value) {
    if (value.isEmpty) {
      return null;
    }
    if (value == null) {
      return 'Please enter your email';
    } else if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
