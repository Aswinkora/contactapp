import 'package:contact/Data/database.dart';
import 'package:contact/pages/editcontact.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ContactDetails extends StatefulWidget {
  final Contact contact;
  const ContactDetails({super.key, required this.contact});

  @override
  State<StatefulWidget> createState() {
    return ContactDetailsState();
  }
}

class ContactDetailsState extends State<ContactDetails> {
  late Contact contact;

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          actions: [
            IconButton(
              onPressed: () async {
                final updatedContact = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactEdit(contact: contact),
                  ),
                );
                if (updatedContact != null) {
                  setState(() {
                    contact = updatedContact;
                  });
                  Navigator.pop(context, updatedContact);
                }
              },
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
        body: Column(
          children: [
            const Gap(10),
            const CircleAvatar(
              radius: 64,
            ),
            Expanded(
                child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.cyan),
                  title: Text(contact.name ?? ''),
                  subtitle: const Text('Name'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.cyan),
                  title: Text(contact.phone?.toString() ?? ''),
                  subtitle: const Text('Telefone'),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.cyan),
                  title: Text(contact.email ?? ''),
                  subtitle: const Text('E-mail'),
                ),
              ],
            )),
          ],
        ));
  }
}
