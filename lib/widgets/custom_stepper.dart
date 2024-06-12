import 'package:flutter/material.dart';
import 'package:v1_rentals/generated/l10n.dart';

class CustomStepperControls extends StatelessWidget {
  final int currentStep;
  final VoidCallback onStepContinue;
  final VoidCallback onStepCancel;
  final bool isLastStep;

  const CustomStepperControls({
    Key? key,
    required this.currentStep,
    required this.onStepContinue,
    required this.onStepCancel,
    required this.isLastStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (currentStep != 0)
          Expanded(
            child: SizedBox(
              height: 50, // Adjust the height as needed
              child: ElevatedButton(
                onPressed: onStepCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(S.of(context).back),
              ),
            ),
          ),
        if (currentStep != 0)
          SizedBox(
            width: 12,
          ),
        Expanded(
          child: SizedBox(
            height: 50, // Adjust the height as needed
            child: ElevatedButton(
              onPressed: onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(isLastStep ? S.of(context).confirm : 'Next'),
            ),
          ),
        ),
      ],
    );
  }
}
