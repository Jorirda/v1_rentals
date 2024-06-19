import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/providers/account_provider.dart';
import 'package:v1_rentals/screens/account/edit_account.dart';
import 'package:v1_rentals/screens/account/languages/languages.dart';
import 'package:v1_rentals/screens/account/payment_overviews/payment_overview.dart';
import 'package:v1_rentals/widgets/shimmer_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountDataProvider>(context, listen: false).fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final accountDataProvider = Provider.of<AccountDataProvider>(context);
    final user = accountDataProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.account),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildUserData(user, localization),
              const SizedBox(height: 20),
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
                              accountDataProvider
                                  .fetchUserData(); // Refresh data
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
                  child: Text(localization.edit_account),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              // MENU

              AccountMenuWidget(
                title: localization.settings,
                icon: Icons.settings,
                onPress: () {},
                textColor: null,
              ),

              AccountMenuWidget(
                title: localization.address_book,
                icon: Icons.book_rounded,
                onPress: () {},
                textColor: null,
              ),

              AccountMenuWidget(
                title: localization.payment_options,
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
                title: localization.language,
                icon: Icons.language,
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LanguageScreen(),
                    ),
                  );
                },
                textColor: null,
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              AccountMenuWidget(
                title: localization.help,
                icon: Icons.help,
                onPress: () {},
                textColor: null,
              ),
              AccountMenuWidget(
                title: localization.logout,
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

  Widget _buildUserData(CustomUser? user, S localization) {
    if (user == null) {
      return Text(localization.no_user_logged_in);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage:
              user.imageURL != null ? NetworkImage(user.imageURL!) : null,
        ),
        const SizedBox(height: 20),
        Text(
          '${user.fullname}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${user.email}',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Text(
          '+(246) ${user.phoneNum}',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
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
