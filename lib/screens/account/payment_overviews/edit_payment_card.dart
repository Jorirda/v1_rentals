import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPaymentCardScreen extends StatefulWidget {
  final String cardId;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;

  const EditPaymentCardScreen({
    required this.cardId,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
  });

  @override
  _EditPaymentCardScreenState createState() => _EditPaymentCardScreenState();
}

class _EditPaymentCardScreenState extends State<EditPaymentCardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController cardNumberController;
  late TextEditingController expiryDateController;
  late TextEditingController cardHolderNameController;
  late TextEditingController cvvCodeController;
  bool isCvvFocused = false;

  @override
  void initState() {
    super.initState();
    cardNumberController = TextEditingController(text: widget.cardNumber);
    expiryDateController = TextEditingController(text: widget.expiryDate);
    cardHolderNameController =
        TextEditingController(text: widget.cardHolderName);
    cvvCodeController = TextEditingController(text: widget.cvvCode);
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryDateController.dispose();
    cardHolderNameController.dispose();
    cvvCodeController.dispose();
    super.dispose();
  }

  Future<void> _updatePaymentCard() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        Map<String, dynamic> cardInfo = {
          'cardNumber': cardNumberController.text,
          'expiryDate': expiryDateController.text,
          'cardHolderName': cardHolderNameController.text,
          'cvvCode': cvvCodeController.text,
          'lastFourDigits': cardNumberController.text
              .substring(cardNumberController.text.length - 4),
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cards')
            .doc(widget.cardId)
            .update(cardInfo);

        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error updating payment card: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Payment Card'),
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
              showBackView: isCvvFocused,
              onCreditCardWidgetChange: (p0) {},
              bankName: 'Scotiabank',
              cardType: CardType.visa,
              isHolderNameVisible: true,
            ),
            SizedBox(height: 20),
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
                // Show confirmation dialog before deleting the card
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm"),
                      content: Text(
                          "Are you sure you want to save changes to this card?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            _updatePaymentCard();
                            Navigator.of(context).pop();
                          },
                          child: Text("Save Changes"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Update Card Information'),
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
