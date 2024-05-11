import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/models/payment_card_model.dart';
import 'package:v1_rentals/screens/account/payment_overviews/add_payment_card.dart';
import 'package:v1_rentals/screens/account/payment_overviews/edit_payment_card.dart';

class PaymentOverviewScreen extends StatefulWidget {
  const PaymentOverviewScreen({Key? key}) : super(key: key);

  @override
  State<PaymentOverviewScreen> createState() => _PaymentOverviewScreenState();
}

class _PaymentOverviewScreenState extends State<PaymentOverviewScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Stream<List<PaymentCard>> _userCardsStream;

  @override
  void initState() {
    super.initState();
    // Initialize _userCardsStream with an empty stream or the actual stream from Firebase
    _userCardsStream = getUserCardsStream();
  }

  Stream<List<PaymentCard>> getUserCardsStream() {
    if (_auth.currentUser != null) {
      // Implement logic to get the stream of user cards from Firebase
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cards')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PaymentCard.fromMap(doc.data()))
              .toList());
    } else {
      // User is not logged in, return an empty stream
      return Stream.value([]);
    }
  }

  void removeCard(String cardId) {
    // Implement logic to remove the card from Firebase
    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cards')
        .doc(cardId)
        .delete()
        .then((_) {
      // Card successfully removed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card successfully removed.'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      // Error occurred while removing card
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove card. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Overview'),
      ),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'Bank Card',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              StreamBuilder<List<PaymentCard>>(
                stream: _userCardsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final cards = snapshot.data ?? [];
                    if (cards.isEmpty) {
                      return Center(child: Text('No cards found'));
                    } else {
                      return Column(
                        children:
                            cards.map((card) => buildCardItem(card)).toList(),
                      );
                    }
                  }
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPaymentCardScreen(),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(20),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            '+ Add Credit/Debit Card',
                            textAlign: TextAlign.center,
                          ),
                          subtitle: Text(
                            'Add your bank account',
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCardItem(PaymentCard card) {
    // Implement how each card item should be displayed
    return Card(
      color: Theme.of(context).colorScheme.primary,
      margin: const EdgeInsets.all(16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              child: Image.asset('assets/images/visa_icon.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Display card information here
                    'XXXX XXXX XXXX ${card.lastFourDigits}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPaymentCardScreen(
                                cardId: card.cardId,
                                cardNumber: card.cardNumber,
                                expiryDate: card.expiryDate,
                                cardHolderName: card.cardHolderName,
                                cvvCode: card.cvvCode,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Text(' | '),
                      TextButton(
                        onPressed: () {
                          // Show confirmation dialog before deleting the card
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirm"),
                                content: Text(
                                    "Are you sure you want to remove this card?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      removeCard(card.cardId);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Remove"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          'Remove',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
