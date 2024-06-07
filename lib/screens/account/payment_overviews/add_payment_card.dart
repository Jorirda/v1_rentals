import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/models/payment_card_model.dart';
import 'package:v1_rentals/providers/payment_provider.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:v1_rentals/generated/l10n.dart';

class AddPaymentCardScreen extends StatefulWidget {
  const AddPaymentCardScreen({super.key});

  @override
  _AddPaymentCardScreenState createState() => _AddPaymentCardScreenState();
}

class _AddPaymentCardScreenState extends State<AddPaymentCardScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).add_payment_card),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CreditCardForm(
                      formKey: formKey,
                      onCreditCardModelChange: onCreditCardModelChange,
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      obscureCvv: true,
                      obscureNumber: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          final newCard = PaymentCard(
                            cardId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            cardNumber: cardNumber,
                            expiryDate: expiryDate,
                            lastFourDigits:
                                cardNumber.substring(cardNumber.length - 4),
                            cardHolderName: cardHolderName,
                            cvvCode: cvvCode,
                          );
                          Provider.of<PaymentProvider>(context, listen: false)
                              .addCard(newCard);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(S.of(context).add_card),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
