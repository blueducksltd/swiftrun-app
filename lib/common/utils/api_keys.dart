import 'package:flutter_dotenv/flutter_dotenv.dart';

String get googleMapApiKey => '${dotenv.env['googleMapKeyAndroid']}';
String get iosMapApiKey => '${dotenv.env['googleMapKeyIOS']}';

// String get secretKey => const String.fromEnvironment("SECRETKEY");
String get secretKey => '${dotenv.env['secretKey']}';

String get paystackSecret => '${dotenv.env['PAYSTACK_SECRET_KEY']}';
String get paystackPublic => '${dotenv.env['PAYSTACK_PUBLIC_KEY']}';
