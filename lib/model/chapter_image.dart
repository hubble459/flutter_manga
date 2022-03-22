class ChapterImage {
  final String url;
  final String referer;
  final String proxy;
  final String proxy2;

  ChapterImage(this.url, this.referer, this.proxy, this.proxy2);

  factory ChapterImage.fromJson(Map<String, dynamic> data) {
    return ChapterImage(data['url'], data['referer'], data['proxy'], data['proxy2']);
  }
}