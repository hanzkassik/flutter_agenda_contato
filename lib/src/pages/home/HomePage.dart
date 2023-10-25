import 'dart:io';

import 'package:agenda_contato/src/helpers/contact_helper.dart';
import 'package:agenda_contato/src/pages/contact/ContactPage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];

  _getContacts() {
    helper.getAllContacts().then((value) {
      setState(() {
        contacts = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Contatos"),
        backgroundColor: Colors.red,
        actions: [
          PopupMenuButton<OrderOptions>(
            onSelected: _orderList,
            itemBuilder: (context) {
              return <PopupMenuEntry<OrderOptions>>[
                PopupMenuItem<OrderOptions>(
                  child: Text("Ordernar de A-Z"),
                  value: OrderOptions.orderaz,
                ),
                PopupMenuItem<OrderOptions>(
                  child: Text("Ordernar de Z-A"),
                  value: OrderOptions.orderza,
                )
              ];
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _ContactCard(context, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _ContactCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null
                        ? FileImage(File(contacts[index].img!))
                        : const AssetImage("assets/images/account.png")
                            as ImageProvider,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].name ?? '',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      contacts[index].phone ?? '',
                      style: const TextStyle(fontSize: 14),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showContactPage({Contact? contact}) async {
    Contact? newContact = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactPage(contact: contact),
        ));
    if (newContact != null) {
      if (contact != null) {
        await helper.updateContact(newContact);
      } else {
        await helper.saveContact(newContact);
      }
      await _getContacts();
    }
  }

  _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse("sms:${contacts[index].phone}"));
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Enviar mensagem",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse("tel:${contacts[index].phone}"));
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Ligar",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                      child: const Text(
                        "Editar",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: () {
                        helper.deleteContact(contacts[index].id!);
                        setState(() {
                          contacts.removeAt(index);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Excluir",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort(
          (a, b) {
            return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
          },
        );
        break;
      case OrderOptions.orderza:
        contacts.sort(
          (a, b) {
            return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
          },
        );
        break;
    }
    setState(() {});
  }
}
