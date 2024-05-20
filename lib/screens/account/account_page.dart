import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1_rentals/screens/account/edit_account.dart';
import 'package:v1_rentals/screens/account/payment_overviews/payment_overview.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late User? _user;
  String? _imageURL;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isEqualTo: _user!.uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.size > 0) {
          setState(() {
            var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
            _imageURL = data['imageURL'];
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              _buildUserData(_user, _imageURL),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAccountScreen(
                          (String? imagePath) {
                            setState(() {
                              _imageURL = imagePath;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Edit Account'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),

              // MENU

              AccountMenuWidget(
                title: 'Settings',
                icon: Icons.settings,
                onPress: () {},
                textColor: null,
              ),

              AccountMenuWidget(
                title: 'Address Book',
                icon: Icons.book_rounded,
                onPress: () {},
                textColor: null,
              ),

              AccountMenuWidget(
                title: 'Payment Options',
                icon: Icons.wallet,
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentOverviewScreen(),
                    ),
                  );
                },
                textColor: null,
              ),
              AccountMenuWidget(
                title: 'Language',
                icon: Icons.language,
                onPress: () {},
                textColor: null,
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              AccountMenuWidget(
                title: 'Help',
                icon: Icons.help,
                onPress: () {},
                textColor: null,
              ),
              AccountMenuWidget(
                title: 'Logout',
                icon: Icons.logout,
                onPress: () {
                  FirebaseAuth.instance.signOut();
                },
                textColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserData(User? user, String? imageURL) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: imageURL != null ? NetworkImage(imageURL) : null,
        ),
        const SizedBox(
          height: 20,
        ),
        StreamBuilder<DocumentSnapshot>(
          stream: _getUserDataStream(user),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const CircularProgressIndicator();
            // }

            if (snapshot.data == null || snapshot.data!.data() == null) {
              return const Text('No Data Found');
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              children: [
                Text(
                  '${data['fullname']}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  ' ${data['email']}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  ' ${data['userType']}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Stream<DocumentSnapshot> _getUserDataStream(User? user) {
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();
    } else {
      throw ArgumentError('User cannot be null');
    }
  }
}

class AccountMenuWidget extends StatelessWidget {
  const AccountMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    required this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.primary)
            .apply(color: textColor),
      ),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(
          Icons.arrow_forward,
          size: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}
