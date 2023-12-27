class UserModel {
  final String name;
  final bool reciepts;
  final String status;
  final String uid;
  final String profilePic;
  final bool isOnline;
  final String phoneNumber;
  final List<String> lockedChats;
  final String lockChatPassword;

  UserModel({
    required this.name,
    required this.reciepts,
    required this.status,
    required this.uid,
    required this.profilePic,
    required this.isOnline,
    required this.phoneNumber,
    required this.lockedChats,
    required this.lockChatPassword,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reciepts': reciepts,
      'status': status,
      'uid': uid,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'phoneNumber': phoneNumber,
      'lockedChats': lockedChats,
      'lockChatPassword': lockChatPassword,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      reciepts: map['reciepts'] ?? true,
      status: map['status'] ?? 'Welcome To Deepfake Prevention Application',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      lockedChats: List<String>.from(map['lockedChats']),
      lockChatPassword: map['lockChatPassword'] ?? '',
    );
  }
}
