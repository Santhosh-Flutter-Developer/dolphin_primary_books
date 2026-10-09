class ProfileModel {
  String? schoolName,
      address,
      city,
      pincode,
      username,
      password,
      landline,
      mobileNumber,
      email,
      website,
      loginFrom,
      loginTo;

  toMap() {
    var mapping = <String, dynamic>{};
    mapping["school_name"] = schoolName;
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["pincode"] = pincode;
    mapping["username"] = username;
    mapping["password"] = password;
    mapping["landline"] = landline;
    mapping["mobileNumber"] = mobileNumber;
    mapping["email"] = email;
    mapping["website"] = website;
    mapping["login_from"] = loginFrom;
    mapping["logn_to"] = loginTo;

    return mapping;
  }
}
