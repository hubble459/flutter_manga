import 'package:flutter/material.dart';
import 'package:manga_reader/model/db_models.dart';

class DownloadChaptersPage extends StatelessWidget {
  final DBManga manga;

  const DownloadChaptersPage({Key? key, required this.manga}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Chapters'),
      ),
    );
  }
}
