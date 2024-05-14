import 'package:contact/Data/database.dart';
import 'package:contact/pages/contactdetails.dart';
import 'package:contact/pages/createcontact.dart';
import 'package:flutter/material.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<StatefulWidget> createState() {
    return ContactListState();
  }
}

class ContactListState extends State<ContactList> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchContact();
    searchController.addListener(filterContacts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterContacts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts.where((contact) {
        return contact.name!.toLowerCase().contains(query) ||
            contact.phone.toString().contains(query) ||
            contact.email!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by name, phone, or email',
                  border: InputBorder.none,
                ),
                autofocus: true,
              )
            : const Text('Contact'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.cancel : Icons.search),
            onPressed: toggleSearch,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: isSearching ? filteredContacts.length : contacts.length,
        itemBuilder: (context, index) {
          final contact =
              isSearching ? filteredContacts[index] : contacts[index];
          return GestureDetector(
            onLongPress: () {
              deleteContact(contact);
            },
            onTap: () async {
              final updatedContact = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ContactDetails(contact: contact),
                ),
              );
              if (updatedContact != null) {
                setState(() {
                  fetchContact();
                });
              }
            },
            child: ListTile(
              leading: const CircleAvatar(
                radius: 20,
              ),
              title: Text(contact.name ?? ''),
              subtitle: Text(contact.phone?.toString() ?? ''),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddContact()),
          );
          if (result != null) {
            setState(() {
              contacts.add(result);
              filterContacts();
            });
          }
        },
      ),
    );
  }

  Future<void> fetchContact() async {
    List<Contact> fetchContacts =
        (await SqlStorage().getdata()).cast<Contact>();
    setState(() {
      contacts = fetchContacts;
      filteredContacts = fetchContacts;
    });
  }

  void deleteContact(Contact contact) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await SqlStorage().delete(contact.id!);
      fetchContact();
    }
  }
}
