import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;
import 'auth.dart' as fbAuth;

/**
 * Upload file here
 */
Future<String> upload(File file, String basename) async {
  await fbAuth.ensureSignIn();

  firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child("Files/Test");

  firebase_storage.UploadTask uploadTask = ref.putFile(file);

  String location = "";
  await uploadTask.whenComplete(() async {
    location = await uploadTask.snapshot.ref.getDownloadURL();
  });

  print("Url: $location");
  print("Name: ${ref.name}");
  print("Bucket: ${ref.bucket}");
  print("Path: ${ref.fullPath}");

  return location;
}

/**
 * Download file here
 */
Future<String> download(Uri path) async {
  http.Response data = await http.get(path);
  return data.body;
}
