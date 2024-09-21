import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfGenerator {
  static late Font arFont;
  static init() async {
    arFont = Font.ttf((await rootBundle.load("assets/fonts/Tajawal-Bold.ttf")));
  }

  static Future<File> createInvoicePdf() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    File file = File("${path}MY_PDF.pdf");

    Document pdf = Document();
    pdf.addPage(_createInvoicePage());

    Uint8List bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    return file;
  }

  static Page _createInvoicePage() {
    return Page(
      textDirection: TextDirection.rtl,
      theme: ThemeData.withFont(
        base: arFont,
      ),
      pageFormat: PdfPageFormat.roll80,
      build: (context) {
        return Padding(
          padding: const EdgeInsets.only(right: 30, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5),
              Text(" مــغــاســل الـهـويـدي",
                  style: const TextStyle(
                    fontSize: 20,
                  )),
              SizedBox(height: 5),
              SizedBox(height: 5),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: PdfColors.black),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  'This is the invoice data',
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: PdfColors.black),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Text('100'),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'فاتورة رقم',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }
}
