class Utils {
  DateTime addMonthsToDate(DateTime date, int monthsToAdd) {
    return DateTime(date.year, date.month + monthsToAdd, date.day);
  }
}
