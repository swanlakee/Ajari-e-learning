import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/provider/auth_provider.dart';
import 'package:uas/services/transaction_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = false;
  Timer? _statusCheckTimer;

  // Predefined amounts
  final List<double> _amounts = [50000, 100000, 250000, 500000, 1000000];

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _processTopUp() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final double? amount = double.tryParse(amountText);

    if (amount == null || amount < 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Minimum top up is Rp 1')));
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    // 1. Create Invoice
    final result = await _transactionService.createInvoice(token, amount);

    if (result['success'] == true) {
      final data = result['data'];
      final invoiceUrl = data['payment_url'];
      final externalId = data['external_id'];

      // 2. Open Xendit URL
      final Uri url = Uri.parse(invoiceUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        // 3. Start Polling for status
        _startPollingStatus(token, externalId);
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch payment URL')),
          );
        }
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to create invoice'),
          ),
        );
      }
    }
  }

  void _startPollingStatus(String token, String externalId) {
    // Poll every 5 seconds
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      final result = await _transactionService.checkStatus(token, externalId);

      if (result['success'] == true && result['status'] == 'PAID') {
        timer.cancel();
        if (mounted) {
          setState(() => _isLoading = false);
          // Show success
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Top Up Successful'),
              content: const Text('Your balance has been updated!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // dialog
                    Navigator.of(context).pop(); // screen
                    context
                        .read<AuthProvider>()
                        .updateProfile(); // refresh balance
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Top Up Balance',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 24),
            const Text(
              'Quick Select',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _amounts.map((amount) {
                return GestureDetector(
                  onTap: () {
                    _amountController.text = amount.toInt().toString();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6EDF7)),
                    ),
                    child: Text(
                      'Rp ${amount.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1665D8),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1665D8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Pay with Xendit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
