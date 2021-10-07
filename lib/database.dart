import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

int counter = 0;
DatabaseReference? counterRef;
DatabaseError? error;

/// Initialize the firebase database here
void init(FirebaseDatabase database) {
  counterRef = database.reference().child('Learning/counter');
  counterRef?.keepSynced(true);
  database.setPersistenceEnabled(true);
  database.setPersistenceCacheSizeBytes(10000000);
  database.setLoggingEnabled(true);
}

/// Retrieve the Data from the Firebase database
Future<Null> getCounter() async {
  int value;
  await counterRef?.once().then((DataSnapshot snapshot) {
    print("Connected to the Database and read ${snapshot.value}");
    value = snapshot.value;
  });
}

/// Add the Data to the Firebase Database
Future<Null> setCounter(int value) async {
  final TransactionResult transactionResult =
  await counterRef!.runTransaction((MutableData mutableData) {
    mutableData.value = value;
    return mutableData;
  });

  if (transactionResult.committed == true) {
    print("Saved value to the Database");
  } else {
    print("Failed to save value to the Database");
    if (transactionResult.error != null) {
      print(transactionResult.error?.message);
    }
  }
}

/// Add Data
Future<Null> addData(String user) async {
  DatabaseReference messageRef =
  FirebaseDatabase.instance.reference().child("Messages/${user}");
  for (int i = 0; i < 20; i++) {
    messageRef.update(<String, String>{'Key$i': 'Value$i'});
  }
}

/// Remove Data
Future<Null> removeData(String user) async {
  DatabaseReference messageRef =
  FirebaseDatabase.instance.reference().child("Messages/${user}");
  await messageRef.remove();
}

/// Set Data
Future<Null> setData(String user, String key, String value) async {
  DatabaseReference messageRef =
  FirebaseDatabase.instance.reference().child("Messages/${user}");
  await messageRef.set(<String, String>{key: value});
}

/// update Data
Future<Null> updateData(String user, String key, String value) async {
  DatabaseReference messageRef =
  FirebaseDatabase.instance.reference().child("Messages/${user}");
  await messageRef.update(<String, String>{key: value});
}

/// find Data
Future<String?> findData(String user, String key) async {
  DatabaseReference messageRef =
  FirebaseDatabase.instance.reference().child("Messages/${user}");
  String? value;
  Query query = messageRef.equalTo(value, key: key);
  await query.once().then((DataSnapshot snapshot) {
    value = snapshot.value.toString();
  });
  return value;
}

/// fine Data By Range
Future<String?> findDataByRange(String user, String key) async {
  DatabaseReference messageRef =
  FirebaseDatabase.instance.reference().child("Messages/${user}");
  String? value = "";
  Query query = messageRef.endAt(value, key: key);
  await query.once().then((DataSnapshot snapshot) {
    value = snapshot.value.toString();
  });
  return value;
}
