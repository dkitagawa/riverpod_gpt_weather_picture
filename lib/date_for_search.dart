import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date_for_search.g.dart';

@riverpod
class DateForSearch extends _$DateForSearch {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}
