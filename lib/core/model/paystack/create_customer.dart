class CreateCustomer {
  String? email;
  String? firstName;
  String? lastName;
  String? phone;
  int? integration;
  String? domain;
  String? customerCode;
  int? id;
  bool? identified;

  CreateCustomer(
      {this.email,
      this.firstName,
      this.lastName,
      this.phone,
      this.integration,
      this.domain,
      this.customerCode,
      this.id,
      this.identified});

  CreateCustomer.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phone = json['phone'];
    integration = json['integration'];
    domain = json['domain'];
    customerCode = json['customerCode'];
    id = json['id'];
    identified = json['identified'];
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'integration': integration,
        'domain': domain,
        'customerCode': customerCode,
        'id': id,
        'identified': identified,
      };
}
