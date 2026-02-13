class PaymentAuthorization {
  String? authorizationUrl;
  String? accessCode;
  String? reference;

  PaymentAuthorization({
    this.authorizationUrl,
    this.accessCode,
    this.reference,
  });

  factory PaymentAuthorization.fromJson(Map<String, dynamic> json) {
    return PaymentAuthorization(
      authorizationUrl: json['authorization_url'],
      accessCode: json['access_code'],
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorization_url': authorizationUrl,
      'access_code': accessCode,
      'reference': reference,
    };
  }
}
