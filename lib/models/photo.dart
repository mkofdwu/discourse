import 'dart:io';

class Photo {
  File? file;
  String? url;
  late bool isLocal;

  Photo.file(this.file) {
    assert(file != null);
    isLocal = true;
  }

  Photo.url(this.url) {
    assert(url != null);
    isLocal = false;
  }

  String get heroTag => isLocal ? file!.path : url!;
}
