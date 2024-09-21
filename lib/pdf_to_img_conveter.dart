import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class PdfConverter {
  static Future<File> convertToImage(String pdfPath) async {
    PdfDocument doc = await PdfDocument.openFile(pdfPath);
    PdfPage page = await doc.getPage(1);

    final PdfPageImage? pageImg = await page.render(
        width: 575, height: page.height + 450, backgroundColor: "#ffffff");

    if (pageImg != null) {
      String path = (await getApplicationDocumentsDirectory()).path;
      File file = File("$path/MY_IMG.png");

      await file.writeAsBytes(pageImg.bytes);
      //OpenFile.open(file.path);
      return file;
    }
    return File("kk.png");
  }
}
