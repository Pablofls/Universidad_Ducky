// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void exportHtml(String htmlContent, String filename) {
  final blob = html.Blob([htmlContent], 'text/html');
  final url  = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  Future.delayed(const Duration(seconds: 2), () => html.Url.revokeObjectUrl(url));
}
