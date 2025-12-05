class Profile {
  final String? uid;
  final String? fullname;
  final String? email;
  final String? photoUrl;

  Profile({this.uid, this.fullname, this.email, this.photoUrl});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      uid: json['uid'],
      fullname: json['fullname'],
      email: json['email'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullname': fullname,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
