import 'package:flutter/material.dart';
import 'package:manga_reader/utils/database.dart';
import 'package:manga_reader/widgets/simple_future_builder.dart';
import 'package:flutter_picker/Picker.dart';

class StatisticsPage extends StatelessWidget {
  static const String routeName = 'statistics';
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
      ),
      body: Column(
        children: [
          _Progress(
            name: "Chapters Read",
            future: () async {
              final DatabaseUtil database = DatabaseUtil.instance;
              return _TotalAndProgress(total: await database.getTotalChapters(), progress: await database.getTotalChaptersRead());
            },
          ),
          _Progress(
            name: "Completed Manga",
            future: () async {
              final DatabaseUtil database = DatabaseUtil.instance;
              return _TotalAndProgress(total: await database.getTotalManga(), progress: await database.getTotalMangaCompleted());
            },
          ),
          SimpleFutureBuilder<int>(
              future: (() async {
                final DatabaseUtil database = DatabaseUtil.instance;
                return await database.getTotalChaptersRead();
              })(),
              onLoadedBuilder: (context, totalChaptersRead) => _AverageReadingTime(totalChaptersRead: totalChaptersRead),
              onLoadingBuilder: (context) => const CircularProgressIndicator())
        ],
      ),
    );
  }
}

class _AverageReadingTime extends StatefulWidget {
  final DatabaseUtil database = DatabaseUtil.instance;
  final int totalChaptersRead;

  _AverageReadingTime({Key? key, required this.totalChaptersRead}) : super(key: key);

  @override
  State<_AverageReadingTime> createState() => __AverageStateReadingTime();
}

class __AverageStateReadingTime extends State<_AverageReadingTime> {
  Duration _averageChapterReadTime = const Duration(minutes: 3);
  late Picker _picker;

  @override
  Widget build(BuildContext context) {
    _picker = Picker(
      columnPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      textStyle: Theme.of(context).textTheme.bodyLarge,
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
            begin: 0, end: 30, suffix: const Text(' minutes'), jump: 1, initValue: _averageChapterReadTime.inMinutes),
        NumberPickerColumn(
            begin: 0,
            end: 50,
            suffix: const Text(' seconds'),
            jump: 10,
            initValue: _averageChapterReadTime.inSeconds.remainder(60)),
      ]),
      hideHeader: true,
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            "Average Reading Time",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        _picker.makePicker(),
        TextButton(
            onPressed: () {
              setState(() {
                _averageChapterReadTime =
                    Duration(minutes: _picker.getSelectedValues()[0], seconds: _picker.getSelectedValues()[1]);
              });
            },
            child: const Text("Recalculate")),
        Text(
          _printDuration(_averageChapterReadTime * widget.totalChaptersRead),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          "DD:HH:MM:SS",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String days = duration.inDays != 0 ? twoDigits(duration.inDays) + ":" : "";
    String twoDigitHours = twoDigits(duration.inHours.remainder(24));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$days$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }
}

class _Progress extends StatelessWidget {
  final String name;
  final Future<_TotalAndProgress> Function() future;

  const _Progress({Key? key, required this.name, required this.future}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              name,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SimpleFutureBuilder<_TotalAndProgress>(
              future: future(),
              onLoadedBuilder: (context, value) => Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(value.progress.toString()),
                          Text((value.total - value.progress).toString()),
                        ],
                      ),
                      Stack(children: [
                        LinearProgressIndicator(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          minHeight: 12,
                          value: percentage(value),
                        ),
                        Center(
                          child: Text(
                            value.total.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(inherit: true, fontSize: 10, color: Theme.of(context).colorScheme.background),
                          ),
                        ),
                      ])
                    ],
                  ),
              onLoadingBuilder: (context) => const LinearProgressIndicator(
                    minHeight: 10,
                  ))
        ],
      ),
    );
  }

  double percentage(_TotalAndProgress value) {
    if (value.total == 0) {
      return 0;
    }
    return 1 / value.total * value.progress;
  }
}

class _TotalAndProgress {
  final int total;
  final int progress;

  const _TotalAndProgress({required this.total, required this.progress});
}
