import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddContactsScreen extends StatefulWidget {
  @override
  _AddContactsScreenState createState() => _AddContactsScreenState();
}

class _AddContactsScreenState extends State<AddContactsScreen> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  Future<void> getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      List<Contact> fetchedContacts = await ContactsService.getContacts();
      setState(() {
        contacts = fetchedContacts;
      });
    }
  }

  Future<void> sendContactsToApi() async {
    var url = Uri.parse('https://example.com/api/contacts');
    List<Map<String, dynamic>> contactsList = contacts.map((contact) {
      return {
        'displayName': contact.displayName ?? '',
        'givenName': contact.givenName ?? '',
        'familyName': contact.familyName ?? '',
        'phones': contact.phones?.map((item) => item.value ?? '').toList(),
        'emails': contact.emails?.map((item) => item.value ?? '').toList(),
      };
    }).toList();

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'contacts': contactsList}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contacts uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload contacts')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contacts'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: sendContactsToApi,
            child: Text('Send Contacts to API'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                Contact contact = contacts[index];
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text(
                    contact.phones!.isNotEmpty
                        ? contact.phones?.first.value ?? ''
                        : '',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
