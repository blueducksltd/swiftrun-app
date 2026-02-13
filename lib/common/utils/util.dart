import 'dart:math';

class Util {
  static uniqueRefenece() {
    const String numbers = '0123456789';
    final Random random = Random.secure();

    String numericPart =
        List.generate(6, (index) => numbers[random.nextInt(numbers.length)])
            .join();

    var fn = int.parse(numericPart);

    log(fn);

    return '$fn';
  }
}
