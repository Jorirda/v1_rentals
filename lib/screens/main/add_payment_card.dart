import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddPaymentCardScreen extends StatefulWidget {
  @override
  _AddPaymentCardScreenState createState() => _AddPaymentCardScreenState();
}

class _AddPaymentCardScreenState extends State<AddPaymentCardScreen> {
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

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
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
          ],
        ),
      ),
    ));
  }
}
