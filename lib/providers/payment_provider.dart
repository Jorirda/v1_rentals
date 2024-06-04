import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/models/payment_card_model.dart';

class PaymentProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PaymentCard> _cards = [];

  List<PaymentCard> get cards => _cards;

  PaymentProvider() {
    _fetchUserCards();
  }

  Future<void> _fetchUserCards() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .snapshots()
          .listen((snapshot) {
        _cards = snapshot.docs
            .map((doc) => PaymentCard.fromMap(doc.data()))
            .toList();
        notifyListeners();
      });
    }
  }

  Future<void> addCard(PaymentCard card) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .doc(card.cardId)
          .set(card.toMap());
    }
  }

  Future<void> updateCard(PaymentCard card) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .doc(card.cardId)
          .update(card.toMap());
    }
  }

  Future<void> removeCard(String cardId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .doc(cardId)
          .delete();
    }
  }
}
