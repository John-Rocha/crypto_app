import 'package:intl/intl.dart';

class Utils {
  static NumberFormat real = NumberFormat.currency(
    locale: 'pt_BR',
    name: 'R\$',
  );
}
