import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:v1_rentals/models/payment_card_model.dart';

class AddPaymentCardScreen extends StatefulWidget {
  @override
  _AddPaymentCardScreenState createState() => _AddPaymentCardScreenState();
}

class _AddPaymentCardScreenState extends State<AddPaymentCardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController cardNumberController = TextEditingController();
  late TextEditingController expiryDateController = TextEditingController();
  late TextEditingController cardHolderNameController = TextEditingController();
  late TextEditingController cvvCodeController = TextEditingController();
  bool isCvvFocused = false;

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryDateController.dispose();
    cardHolderNameController.dispose();
    cvvCodeController.dispose();
    super.dispose();
  }

  Future<void> _addPaymentCard(PaymentCard card) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Convert PaymentCard object to a map
        Map<String, dynamic> cardInfo = card.toMap();

        // Add the card information to a subcollection under the user's document
        // Use the cardId as the document ID
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cards')
            .doc(card.cardId) // Use cardId as document ID
            .set(cardInfo);

        // Show success message or navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle errors
      print('Error adding payment card: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Payment Card'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CreditCardWidget(
              cardNumber: cardNumberController.text,
              expiryDate: expiryDateController.text,
              cardHolderName: cardHolderNameController.text,
              cvvCode: cvvCodeController.text,
              showBackView:
                  isCvvFocused, //true when you want to show cvv(back) view
              onCreditCardWidgetChange: (CreditCardBrand brand) {},
              bankName: 'Scotiabank',
              labelCardHolder: 'John Doe',
              isHolderNameVisible: true,
              cardType: CardType.visa,
              isChipVisible: true,
              obscureCardCvv: false,
            ),
            SizedBox(height: 20),

            //Credit Card Form
            CreditCardForm(
              formKey: formKey,
              cardNumber: cardNumberController.text,
              expiryDate: expiryDateController.text,
              cardHolderName: cardHolderNameController.text,
              cvvCode: cvvCodeController.text,
              onCreditCardModelChange: (CreditCardModel creditCardModel) {
                setState(() {
                  cardNumberController.text = creditCardModel.cardNumber;
                  expiryDateController.text = creditCardModel.expiryDate;
                  cardHolderNameController.text =
                      creditCardModel.cardHolderName;
                  cvvCodeController.text = creditCardModel.cvvCode;
                });
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Generate a cardId using Firestore's document ID generation
                String cardId = _firestore.collection('dummy').doc().id;
                // Call the _addPaymentCard function and pass the necessary arguments
                _addPaymentCard(PaymentCard(
                  cardId: cardId, // Assign the generated cardId
                  cardNumber: cardNumberController.text,
                  expiryDate: expiryDateController.text,
                  cardHolderName: cardHolderNameController.text,
                  cvvCode: cvvCodeController.text,
                  lastFourDigits: cardNumberController.text
                      .substring(cardNumberController.text.length - 4),
                  // Add other fields as needed
                ));
              },
              child: Text('Add Card'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
