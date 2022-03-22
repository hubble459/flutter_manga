import 'package:jiffy/jiffy.dart';
import 'package:manga_scraper/manga_scraper.dart';

int avgDifference(List<Jiffy?> postedDates) {
  if (postedDates.length < 2) {
    return 0;
  } else {
    final int size = postedDates.length - 1;
    int total = 0;
    for (int i = 0; i < size; i++) {
      total +=
          (postedDates[i]?.dateTime.millisecondsSinceEpoch ?? 0) - (postedDates[i + 1]?.dateTime.millisecondsSinceEpoch ?? 0);
    }
    return (total / size).round();
  }
}

String? relativeDiff(int diff) {
  if (diff == 0) {
    return null;
  }

  final future = Jiffy();
  future.add(milliseconds: diff);
  return future.fromNow();
}
