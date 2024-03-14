import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nova/constant/global.dart';
import 'package:nova/utils/commons.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewScreen extends StatefulWidget {
  final String pdfUrl;

  PdfViewScreen(
    this.pdfUrl,
  );

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {

  bool downLoadingPDF = true;
  double _progress = 0;
  PDFDocument document;

  get downloadProgress => _progress;
  get downloadProgressText => _progress * 100;
  double downloadProgressTextRound = 0;

  void loadDocument() async {

    document = await PDFDocument.fromURL(widget.pdfUrl);
    
    _progress = null;
    final url = widget.pdfUrl;
    final request = Request('GET', Uri.parse(url));
    final StreamedResponse response = await Client().send(request);

    final contentLength = response.contentLength;

    _progress = 0;

    List<int> bytes = [];
    String extension = "." + widget.pdfUrl.split('.').last;
    final file = await _getFile('novaPDF' + extension);
    response.stream.listen(
          (List<int> newBytes) {
        bytes.addAll(newBytes);
        if (mounted) {
          setState(() {
            final downloadedLength = bytes.length;
            _progress = downloadedLength / contentLength;
            double percentage = _progress * 100;
            downloadProgressTextRound = percentage.roundToDouble();
          });
        }
      },
      onDone: () async {
        await file.writeAsBytes(bytes);
        if (mounted) {
          setState(() {
            downLoadingPDF = false;
          });
        }
      },
      onError: (e) {
      },
      cancelOnError: true,
    );
  }

  Future<File> _getFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/$filename");
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    loadDocument();
  }


  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: appColor,
            centerTitle: true,
            title: Text('PDF Viewer',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'DMSans-Regular')),
            leading: Container(
              child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(appColor),
                      foregroundColor: MaterialStateProperty.all(appColor)),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  }),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: Colors.white,
                ),
                onPressed: () async {
                  File pdfFileDownloaded = await getFileFromUrl(widget.pdfUrl);
                  if (pdfFileDownloaded != null) {
                    Share.shareFiles(
                      [pdfFileDownloaded.path],
                    );
                  } else {
                    Commons.novaFlushBarError(
                        context, "Error creating PDF file.");
                  }
                },
              ),
            ]),
        body: Center(
            child: downLoadingPDF
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        child: CircularProgressIndicator(
                          value: _progress *100,
                          strokeWidth: 4.0,
                          color: appColor,
                        ),
                        height: 80.0,
                        width: 80.0,
                      ),
                      Text(
                        '${(_progress * 100).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 12.0, color: appColor),
                      ),
                    ],
                  )
                : PDFViewer(
                    document: document,
                    showIndicator: false,
                    scrollDirection: Axis.vertical,
                    showNavigation: false,
                    enableSwipeNavigation: false,
                    showPicker: false,
                    lazyLoad: false,
                    zoomSteps: 1,
                    progressIndicator: CircularProgressIndicator(
                      color: appColor,
                    ))));
  }

  Future<File> getFileFromUrl(String uri) async {
    EasyLoading.show(status: 'Creating pdf file...');
    final Random _random = Random.secure();
    var values = List<int>.generate(5, (i) => _random.nextInt(256));
    String crypto = base64Url.encode(values);
    var fileName = 'nova' + crypto.toString();
    try {
      var _uri = Uri.parse(uri);
      var data = await http.get(_uri);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" + fileName + ".pdf");
      print(dir.path);
      EasyLoading.dismiss();
      return await file.writeAsBytes(bytes);
    } catch (e) {
      EasyLoading.dismiss();
      return null;
    }
  }
}
