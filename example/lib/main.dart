import 'package:flutter_android_package_installer/flutter_android_package_installer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _installationStatus = '';
  final TextEditingController _filePathFieldController =
      TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example'),
        ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: TextField(
                              controller: _filePathFieldController,
                              decoration: const InputDecoration(
                                  labelText: "APK file path",
                                  hintText: "Enter path"))),
                      _button('Select file', () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['apk']);
                        if (result != null) {
                          setState(() {
                            _filePathFieldController.text =
                                result.files.single.path!;
                            _installationStatus = '';
                          });
                        }
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                      'PackageManager installation status: $_installationStatus'),
                  const SizedBox(height: 30),
                  _button('Install apk file session', () async {
                    if (_filePathFieldController.text.isNotEmpty) {
                      setState(() {
                        _installationStatus = '';
                      });
                      try {
                        int? code =
                            await AndroidPackageInstaller.installApkSession(
                                apkFilePath: _filePathFieldController.text);
                        if (code != null) {
                          setState(() {
                            _installationStatus =
                                PackageInstallerStatus.byCode(code).name;
                          });
                        }
                      } on PlatformException {
                        print('Error at Platform. Failed to install apk file.');
                      }
                    }
                  }),
                  _button('Install apk file', () async {
                    if (_filePathFieldController.text.isNotEmpty) {
                      setState(() {
                        _installationStatus = '';
                      });
                      try {
                        int? code = await AndroidPackageInstaller.installApk(
                            apkFilePath: _filePathFieldController.text);
                        if (code != null) {
                          setState(() {
                            _installationStatus =
                                PackageInstallerStatus.byCode(code).name;
                          });
                        }
                      } on PlatformException {
                        print('Error at Platform. Failed to install apk file.');
                      }
                    }
                  }),
                  _button('platformVersion', () async {
                    try {
                      String? platformVersion =
                          await AndroidPackageInstaller.platformVersion;
                      if (platformVersion != null) {
                        setState(() {
                          _installationStatus = platformVersion;
                        });
                      }
                    } on PlatformException {
                      print('Error at Platform. Failed to install apk file.');
                    }
                  }),
                  _button('openAppMarket', () async {
                    try {
                      await AndroidPackageInstaller.openAppMarket();
                    } on PlatformException {
                      print('Error at Platform. Failed to install apk file.');
                    }
                  }),
                  _button('openAppSettingDetails', () async {
                    try {
                      await AndroidPackageInstaller.openAppSettingDetails();
                    } on PlatformException {
                      print('Error at Platform. Failed to install apk file.');
                    }
                  }),
                  const Spacer(),
                  SizedBox(
                    child: Column(children: [
                      const Text('Permissions:'),
                      _button('External Storage',
                          () => _requestPermission(Permission.storage)),
                      _button(
                          'Request Install Packages',
                          () => _requestPermission(
                              Permission.requestInstallPackages)),
                      _button(
                          'Manage External Storage\n(for Android 11+ target)',
                          () => _requestPermission(
                              Permission.manageExternalStorage)),
                    ]),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  ElevatedButton _button(String text, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  void _requestPermission(Permission permission) async {
    var status = await permission.status;
    if (status.isDenied) {
      await permission.request();
    }
  }
}
