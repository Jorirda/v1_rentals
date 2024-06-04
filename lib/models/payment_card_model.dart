class PaymentCard {
  final String cardId;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvvCode;
  final String
      lastFourDigits; // Assuming you want to store the last four digits separately
  // Add more fields as needed

  PaymentCard({
    required this.cardId,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvvCode,
    required this.lastFourDigits,
    // Add more parameters as needed
  });

  // Define the fromMap method to create a PaymentCard object from a map
  factory PaymentCard.fromMap(Map<String, dynamic> map) {
    return PaymentCard(
      cardId: map['cardId'],
      cardNumber: map['cardNumber'],
      cardHolderName: map['cardHolderName'],
      expiryDate: map['expiryDate'],
      cvvCode: map['cvvCode'],
      lastFourDigits: map['lastFourDigits'],
    );
  }

  // Define the toMap method to convert a PaymentCard object to a map
  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvvCode': cvvCode,
      'lastFourDigits': lastFourDigits,
      // Add other fields here as needed
    };
  }
}
