//@dart=2.9
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:docxtpl/docxtpl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Word App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // word documents templates
  final assetTpl = 'assets/invite.docx';

  // keys should correspond to fields obtained from [docxTpl.getMergeFields()]
  var templateData = {
    'data': "data",
  };

  Map<String, String> as = {};
  List<String> qs = [
    "A cara cara navel is a type of orange",
    "There are five different blood groups",
    "Cinderella was the first Disney princess",
    "ASOS stands for As Seen On Screen",
  ];

  bool loading = false;

  String savedFile = '';

  List<String> mergeFields = [];

  @override
  void initState() {
    askPermissions();
    super.initState();
  }

  Future<void> askPermissions() async {
    await [
      Permission.storage,
    ].request();
  }

  Future openFile() async {
    try {
      await OpenFile.open(savedFile);
    } catch (e) {
      // error
      print('[ERROR] Failed to open file: $savedFile');
    }
  }

  Future<void> generateDocumentFromAssetTpl() async {
    setState(() {
      loading = true;
    });

    final directory = await getTemporaryDirectory();
    var filename = path.join(directory.path, 'generated_tpl_asset.docx');

    var saveTo = await File(filename).create(recursive: true);

    final DocxTpl docxTpl = DocxTpl(
      docxTemplate: 'assets/invite.docx',
      isAssetFile: true,
    );

    var r = await docxTpl.parseDocxTpl();
    print(r.mergeStatus == MergeResponseStatus.Success);
    print(r.message);

    var fields = docxTpl.getMergeFields();

    print('[INFO] asset template file fields found: ');
    print(fields);

    String data = " [ ";
    as.forEach((key, value) {
      data = "$data { $key : $value },";
    });
    data = "$data ]";

    // keys should correspond to fields obtained from [docxTpl.getMergeFields()]
    await docxTpl.writeMergeFields(data: {"data": data});

    var savedAsset = await docxTpl.save(saveTo.path);

    print('[INFO] Generated document [asset] saved to: $savedAsset');

    setState(() {
      mergeFields = fields;
      loading = false;
      savedFile = savedAsset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            loading
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ))
                : SizedBox.shrink(),
            for (int i = 0; i < qs.length; i++)
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(qs[i]),
                    RadioListTile(
                      title: Text("Yes"),
                      value: "yes",
                      groupValue: as[qs[i]],
                      onChanged: (value) {
                        setState(() {
                          as[qs[i]] = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text("No"),
                      value: "no",
                      groupValue: as[qs[i]],
                      onChanged: (value) {
                        setState(() {
                          as[qs[i]] = value.toString();
                        });
                      },
                    ),
                  ],
                ),
              ),
            TextButton(
              onPressed: () async => await generateDocumentFromAssetTpl(),
              child: Text('Generate docx file'),
            ),
            SizedBox(height: 30),
            Divider(
              thickness: 2,
              height: 1,
            ),
            SizedBox(height: 30),
            Text('Generated word document saved to:'),
            SizedBox(height: 5),
            Text(
              savedFile,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 30),
            Divider(
              thickness: 2,
              height: 1,
            ),
            SizedBox(height: 30),
            TextButton(
              onPressed: () async => await openFile(),
              child: Text('Open generated file'),
            ),
            SizedBox(height: 30),
            Divider(
              thickness: 2,
              height: 1,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
