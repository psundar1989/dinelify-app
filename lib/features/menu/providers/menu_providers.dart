import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/menu_day.dart';
import '../../../data/providers.dart';

DateTime startOfWeek(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

final weeklyMenuProvider = FutureProvider.autoDispose<List<MenuDayModel>>((ref) {
  return ref.watch(menuRepositoryProvider).weekly(startDate: startOfWeek(DateTime.now()));
});

/// Keyed by 'yyyy-MM-dd' string (not DateTime) to avoid family cache misses
/// from DateTime instances that represent the same day but differ in
/// time-of-day/precision.
final menuDayProvider = FutureProvider.autoDispose.family<MenuDayModel, String>((ref, dateKey) {
  return ref.watch(menuRepositoryProvider).day(DateFormat('yyyy-MM-dd').parse(dateKey));
});
