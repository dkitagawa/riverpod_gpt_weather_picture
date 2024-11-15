import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'area_for_search.g.dart';

@riverpod
class AreaForSearch extends _$AreaForSearch {
  @override
  String build() => "東京";

  void setArea(String area) {
    state = area;
  }

}
