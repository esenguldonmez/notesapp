import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esengulnotlar/authentication/loginpage.dart';
import 'package:esengulnotlar/service/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'notedetailpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _createForm = GlobalKey<FormState>();
  TextEditingController baslik = TextEditingController();
  TextEditingController not = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      endDrawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(FirebaseAuth.instance.currentUser!.email.toString()),
            const SizedBox(height: 10),
            TextButton(
              child: const Text("Tüm Notları Sil",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              onPressed: () {
                showDialog(context: context, builder: (context) => deleteAll());
              },
            ),
            TextButton(
              child: const Text("Çıkış Yap",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              onPressed: () {
                showDialog(context: context, builder: (context) => cikisYap());
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Notlarım", style: TextStyle(color: Colors.black)),
        actionsIconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            baslik.clear();
            not.clear();
            showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                titlePadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                contentPadding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Not Ekle",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                children: [
                  Form(
                    key: _createForm,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextFormField(
                            controller: baslik,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: "Not Başlığı",
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                            ),
                            validator: (value) {
                              if (value!.length < 3)
                                return "Başlık minimum 3 karakter içermelidir.";
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextFormField(
                            controller: not,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Not",
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1),
                              ),
                            ),
                            validator: (value) {
                              if (value!.length < 10)
                                return "Not minimum 10 karakter içermelidir.";
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            color: Colors.black,
                            child: const Text("Kaydet",
                                style: TextStyle(color: Colors.white)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () async {
                              if (_createForm.currentState!.validate()) {
                                await FirestoreService().createNewNote(
                                    baslik.text.trim(), not.text.trim());
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("notes")
            .where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2));
          } else if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Hiç Notunuz Yok"));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return noteCard(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NoteDetailPage(
                              doc: snapshot.data!.docs.elementAt(index))),
                    );
                  }, snapshot.data!.docs.elementAt(index), index);
                },
              );
            }
          } else {
            return const Text("Hata", style: TextStyle(color: Colors.black));
          }
        },
      ),
    );
  }

  Widget noteCard(Function() onTap, QueryDocumentSnapshot doc, int index) {
    return Dismissible(
      background: Container(
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      key: ValueKey<int>(index),
      onDismissed: (DismissDirection direction) async {
        await FirebaseFirestore.instance
            .collection("notes")
            .doc(doc.id)
            .delete();
        setState(() {});
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0.75, color: Colors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc["title"],
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(dateFromTimestamp(doc["createdDate"]),
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              Text(
                doc["note"],
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String dateFromTimestamp(tarih) {
    DateTime dt = (tarih as Timestamp).toDate();
    return DateFormat('dd/MM/yyyy, HH:mm').format(dt);
  }

  AlertDialog deleteAll() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text("Tüm notlarınız silinsin mi? "),
      actions: [
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Text("Vazgeç", style: TextStyle(color: Colors.black)),
          color: Colors.grey,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Text("Sil", style: TextStyle(color: Colors.white)),
          color: Colors.red,
          onPressed: () async {
            var collection = FirebaseFirestore.instance.collection('notes');
            var snapshots = await collection
                .where("userID",
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .get();
            for (var doc in snapshots.docs) {
              await doc.reference.delete();
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  AlertDialog cikisYap() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text("Çıkış yapılsın mı?"),
      actions: [
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Text("Vazgeç", style: TextStyle(color: Colors.black)),
          color: Colors.grey,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Text("Evet", style: TextStyle(color: Colors.white)),
          color: Colors.red,
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            final box = GetStorage();
            box.remove("mail");
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false);
          },
        ),
      ],
    );
  }
}
