import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/models/payment_card_model.dart';
import 'package:v1_rentals/providers/payment_provider.dart';
import 'package:v1_rentals/screens/account/payment_overviews/add_payment_card.dart';
import 'package:v1_rentals/screens/account/payment_overviews/edit_payment_card.dart';
import 'package:v1_rentals/generated/l10n.dart';

class PaymentOverviewScreen extends StatelessWidget {
  const PaymentOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).payment_overview),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      S.of(context).add_credit_debit,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Consumer<PaymentProvider>(
                    builder: (context, paymentProvider, child) {
                      final cards = paymentProvider.cards;
                      if (cards.isEmpty) {
                        return Center(child: Text(S.of(context).no_card_found));
                      } else {
                        return Column(
                          children: cards
                              .map((card) => buildCardItem(context, card))
                              .toList(),
                        );
                      }
                    },
                  ),

                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => AddPaymentCardScreen(),
                  //       ),
                  //     );
                  //   },
                  //   child: Card(
                  //     margin: EdgeInsets.all(20),
                  //     elevation: 3,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: const Padding(
                  //       padding: EdgeInsets.all(8),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           ListTile(
                  //             title: Text(
                  //               '+ Add Credit/Debit Card',
                  //               textAlign: TextAlign.center,
                  //             ),
                  //             subtitle: Text(
                  //               'Add your bank account',
                  //               textAlign: TextAlign.center,
                  //             ),
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FloatingActionButton(
              shape: const CircleBorder(side: BorderSide.none),
              elevation: 5,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPaymentCardScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                size: 35,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCardItem(BuildContext context, PaymentCard card) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: GestureDetector(
          onTap: () {
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
          child: Column(
            children: [
              CreditCardWidget(
                cardNumber: card.cardNumber,
                expiryDate: card.expiryDate,
                cardHolderName: card.cardHolderName,
                cvvCode: card.cvvCode,
                showBackView: false,
                onCreditCardWidgetChange: (p0) {},
                bankName: 'Scotiabank',
                cardType: CardType.visa,
                isHolderNameVisible: true,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
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
                        S.of(context).edit,
                      ),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Show confirmation dialog before deleting the card
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(S.of(context).confirm),
                              content: Text(S.of(context).confirm_remove),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(S.of(context).cancel),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Provider.of<PaymentProvider>(context,
                                            listen: false)
                                        .removeCard(card.cardId);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(S.of(context).remove),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        S.of(context).delete,
                      ),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
