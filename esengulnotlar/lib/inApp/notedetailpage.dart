// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteDetailPage extends StatefulWidget {
  NoteDetailPage({required this.doc, Key? key}) : super(key: key);
  QueryDocumentSnapshot doc;
  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _editForm = GlobalKey<FormState>();
  TextEditingController baslik = TextEditingController();
  TextEditingController not = TextEditingController();

  bool duzenle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actionsIconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Not Detayı", style: TextStyle(color: Colors.black)),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _editForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Oluşturma Tarihi: ',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  children: <TextSpan>[
                    TextSpan(
                        text: dateFromTimestamp(widget.doc["createdDate"]),
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Düzenleme Tarihi: ',
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                  children: <TextSpan>[
                    TextSpan(
                        text: dateFromTimestamp(widget.doc["editedDate"]),
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: baslik,
                maxLines: 1,
                enabled: duzenle,
                decoration: InputDecoration(
                  hintText: "Not Başlığı",
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.all(8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.5),
                  ),
                  disabledBorder: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value!.length < 3)
                    return "Başlık mininum 3 karakter içermelidir.";
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: not,
                maxLines: 15,
                enabled: duzenle,
                decoration: InputDecoration(
                  hintText: "Not",
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.all(8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 0.5),
                  ),
                  disabledBorder: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value!.length < 3)
                    return "Not mininum 10 karakter içermelidir.";
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        label: duzenle
            ? Row(
                children: const [
                  Text("Kaydet", style: TextStyle(color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.save, color: Colors.white)
                ],
              )
            : Row(
                children: const [
                  Text("Notu Düzenle", style: TextStyle(color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.edit, color: Colors.white),
                ],
              ),
        onPressed: () async {
          if (!duzenle) {
            setState(
              () => duzenle = true,
            );
          } else {
            if (_editForm.currentState!.validate()) {
              await FirebaseFirestore.instance
                  .collection("notes")
                  .doc(widget.doc.id)
                  .update({
                "title": baslik.text.trim(),
                "note": not.text.trim(),
                "editedDate": DateTime.now(),
              });
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }

  String dateFromTimestamp(tarih) {
    DateTime dt = (tarih as Timestamp).toDate();
    return DateFormat('dd/MM/yyyy, HH:mm').format(dt);
  }

  @override
  void initState() {
    baslik.text = widget.doc["title"];
    not.text = widget.doc["note"];
    super.initState();
  }
}
