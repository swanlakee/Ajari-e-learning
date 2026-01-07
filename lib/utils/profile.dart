class Profile {
  final String? uid;
  final String? fullname;
  final String? email;
  final String? photoUrl;
  final double? balance;

  Profile({this.uid, this.fullname, this.email, this.photoUrl, this.balance});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      uid: json['uid'],
      fullname: json['fullname'],
      email: json['email'],
      photoUrl:
          json['photoUrl'] ??
          json['photo_url'] ??
          _generateDefaultAvatar(json['name'] ?? json['fullname'] ?? 'User'),
      balance: double.tryParse(json['balance']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullname': fullname,
      'email': email,
      'photoUrl': photoUrl,
      'balance': balance,
    };
  }

  static String _generateDefaultAvatar(String name) {
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=1665D8&color=fff&size=128';
  }
}
