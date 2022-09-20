import 'package:http/http.dart';
import 'package:html/parser.dart';

class UrlData {
  final String title;
  final String description;
  final String? photoUrl;

  const UrlData(this.title, this.description, this.photoUrl);
}

Future<UrlData?> getUrlData(String url) async {
  try {
    final response = await get(Uri.parse(url));
    final document = parse(response.body);
    final data = {};
    for (final el in document.getElementsByTagName('meta')) {
      if (!el.attributes.containsKey('property')) continue;
      if (el.attributes['property']!.startsWith('og:')) {
        data[el.attributes['property']] = el.attributes['content'];
      }
    }
    if (!data.containsKey('og:title') || !data.containsKey('og:description')) {
      return null;
    }
    return UrlData(
      data['og:title']!,
      data['og:description']!,
      data['og:image'],
    );
  } catch (e) {
    // invalid url or smth
    return null;
  }
}
