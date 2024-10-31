import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date_for_search.g.dart';

@riverpod
class DateForSearch extends _$DateForSearch {
  @override
  String build() => "今日";

  void setDate(String date) {
    state = date;
  }
}