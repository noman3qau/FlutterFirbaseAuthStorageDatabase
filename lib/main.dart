import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart'; // need for basename

import 'auth.dart' as fbAuth;
import 'storage.dart' as fbStorage;
import 'database.dart' as fbDatabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = "";
  String _location = "";

  @override
  void initState() {
    _status = "Not Authenticated";
    _signIn();
    super.initState();
  }

  /// Sign here
  void _signIn() async {
    if (await fbAuth.signInWithGoogle()) {
      setState(() {
        _status = "Signed In with Google.";
      });

      /// Init Firebase Database Call
      _initDatabse();
    } else {
      setState(() {
        _status = "Couldn't SignIn.";
      });
    }
  }

  /// Sign out here
  void _signOut() async {
    if (await fbAuth.signOut()) {
      setState(() {
        _status = "Sign Out.";
      });
    } else {
      setState(() {
        _status = "Sign In.";
      });
    }
  }

  /// Upload file from here
  void _upload() async {
    Directory systemTempDir = Directory.systemTemp;
    File file = await File('${systemTempDir.path}/testFile.txt').create();
    await file.writeAsString("Hello I am as text in the testing file");

    String location = await fbStorage.upload(file, basename(file.path));

    setState(() {
      _location = location;
      _status = "File Uploaded";
    });
  }

  /// Download file here
  void _download() async {
    if (_location.isEmpty) {
      setState(() {
        _status = "File upload first";
      });
      return;
    }

    Uri location = Uri.parse(_location);
    String data = await fbStorage.download(location);

    setState(() {
      _status = "File Downloaded: ${data}";
    });
  }

  /// Initialize Database and Subscribe for Database Listening
  void _initDatabse() async {
    fbDatabase.init(FirebaseDatabase.instance);

    // Listen to the Database change for counter ref only
    fbDatabase.counterRef?.onValue.listen((event) {
      setState(() {
        fbDatabase.error = null;
        fbDatabase.counter = event.snapshot.value ?? 0;
      });
    }, onError: (Object error) {
      setState(() {
        fbDatabase.error = error as DatabaseError?;
      });
    });
  }

  ///Increment in the database value
  void _increment() {
    fbDatabase.setCounter(fbDatabase.counter + 1);
  }

  ///Decrement in the database value
  void _decrement() {
    fbDatabase.setCounter(fbDatabase.counter - 1);
  }

  /// Add Data into Database
  void _addData() async {
    await fbDatabase.addData(await fbAuth.userId());
    setState(() {
      _status = "Data Added";
    });
  }

  /// Remove data from Database
  void _removeData() async {
    await fbDatabase.removeData(await fbAuth.userId());
    setState(() {
      _status = "Data Removed";
    });
  }

  /// Set data to the Database
  void _setData(String key, String value) async {
    await fbDatabase.setData(await fbAuth.userId(), key, value);
    setState(() {
      _status = "Data Set";
    });
  }

  /// Set update the Data into the Database
  void _updateData(String key, String value) async {
    await fbDatabase.updateData(await fbAuth.userId(), key, value);
    setState(() {
      _status = "Data Updated";
    });
  }

  /// Find Data from the Database
  void _findData(String key) async {
    String? value = await fbDatabase.findData(await fbAuth.userId(), key);
    setState(() {
      _status = value!;
    });
  }

  /// Find Data by Range from the Database
  void _findDataByRange(String key) async {
    String? value = await fbDatabase.findDataByRange(await fbAuth.userId(), key);
    setState(() {
      _status = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text("Sample App")),
          body: Container(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Text(_status),
                  new Text('Counter ${fbDatabase.counter}'),
                  new Text('Error: ${fbDatabase.error.toString()}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new ElevatedButton(
                        onPressed: _signOut,
                        child: new Text('Sign out'),
                      ),
                      new ElevatedButton(
                        onPressed: _signIn,
                        child: new Text('Sign in Google'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new ElevatedButton(
                        onPressed: _upload,
                        child: new Text('Upload'),
                      ),
                      new ElevatedButton(
                        onPressed: _download,
                        child: new Text('Download'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new ElevatedButton(
                        onPressed: _increment,
                        child: new Text('Increment'),
                      ),
                      new ElevatedButton(
                        onPressed: _decrement,
                        child: new Text('Decrement'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new ElevatedButton(
                        onPressed: _addData,
                        child: new Text('Add Data'),
                      ),
                      new ElevatedButton(
                        onPressed: _removeData,
                        child: new Text('Remove Data'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new ElevatedButton(
                        onPressed: () => _setData("Key3", "This to Set Data"),
                        child: new Text('Set Data'),
                      ),
                      new ElevatedButton(
                        onPressed: () =>
                            _updateData("Key3", "This to Update Data"),
                        child: new Text('Update Data'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new ElevatedButton(
                        onPressed: () => _findData("Key2"),
                        child: new Text('Find Data'),
                      ),
                      new ElevatedButton(
                        onPressed: () => _findDataByRange("Key11"),
                        child: new Text('Find Data By Range'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}
