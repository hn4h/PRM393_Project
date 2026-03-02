import 'package:flutter/material.dart';

class StepPayment extends StatelessWidget {
  const StepPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Choose a payment method",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          "Credit Card",
          "Secure and fast payment",
          Icons.credit_card,
        ),
        _buildPaymentOption(
          "PayPal",
          "Secure and fast payment",
          Icons.account_balance_wallet_outlined,
        ),
        _buildPaymentOption(
          "Apple Pay",
          "Secure and fast payment",
          Icons.apple,
        ),
        _buildPaymentOption(
          "Google Pay",
          "Secure and fast payment",
          Icons.payment,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: Icon(icon, color: Colors.black),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Radio(value: false, groupValue: true, onChanged: (v) {}),
      ),
    );
  }
}
