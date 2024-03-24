class Filter {

  DateTime? startDate = DateTime(DateTime.now().year,  DateTime.now().month + 1, 1);
  DateTime? finalDate  = DateTime(DateTime.now().year,  DateTime.now().month + 2, 0);
  bool isPaid = false;

}