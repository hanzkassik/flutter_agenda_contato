// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:agenda_contato/src/helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({
    Key? key,
    this.contact,
  }) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late Contact _editContact;
  bool _userEdited = false;
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editContact = Contact();
    } else {
      _editContact = widget.contact!;
      _nameController.text = _editContact.name ?? "";
      _emailController.text = _editContact.email ?? "";
      _phoneController.text = _editContact.phone ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.red,
          title: Text(_editContact.name ?? "New Contact"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_userEdited && _nameController.text.isNotEmpty) {
              Navigator.pop(context, _editContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  picker.pickImage(source: ImageSource.camera).then((value) {
                    if (value != null) {
                      setState(() {
                        _editContact.img = value.path;
                        _userEdited = true;
                      });
                    }
                  });
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editContact.img != null
                          ? FileImage(File(_editContact.img!))
                          : const AssetImage("assets/images/account.png")
                              as ImageProvider,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
                onChanged: (value) {
                  _userEdited = true;
                  setState(() {
                    _editContact.name = value;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
                onChanged: (value) {
                  _userEdited = true;
                  _editContact.email = value;
                },
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone",
                ),
                onChanged: (value) {
                  _userEdited = true;
                  _editContact.phone = value;
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Descartar alterações?"),
            content: const Text("Se sair as alterações serão perdidas."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Sim"),
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
