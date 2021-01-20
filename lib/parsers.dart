class Parsers {
  static DateTime toDateTime(String data) {
    List<String> d = data.split(' ');
    List<String> date = d[1].split('-');
    List<String> time = d[2].split(':');
    DateTime dt = DateTime(
        int.parse(date[0]),
        int.parse(date[1]),
        int.parse(date[2]),
        int.parse(time[0]),
        int.parse(time[1]),
        int.parse(time[2].substring(0, 2)));
    return dt;
  }
}
