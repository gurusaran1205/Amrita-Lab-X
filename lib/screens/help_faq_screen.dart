import 'package:flutter/material.dart';
import '../utils/colors.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        backgroundColor: AppColors.primaryMaroon,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          FaqItem(
            question: 'How do I book a lab slot?',
            answer:
                'To book a lab slot, go to the home screen and tap on the "Book a Slot" button. You will be prompted to select a lab, date, and time. Once you have made your selections, tap on the "Confirm" button to complete your booking.',
          ),
          FaqItem(
            question: 'How do I cancel a booking?',
            answer:
                'To cancel a booking, go to the "My Bookings" screen and find the booking you wish to cancel. Tap on the "Cancel" button and confirm your decision.',
          ),
          FaqItem(
            question: 'Can I book multiple slots at once?',
            answer:
                'Yes, you can book multiple slots at once, subject to availability and any restrictions set by the lab administrator.',
          ),
          FaqItem(
            question: 'What happens if I miss my booking?',
            answer:
                'If you miss your booking, it will be marked as a "No Show". Repeated no-shows may result in a temporary suspension of your booking privileges.',
          ),
          FaqItem(
            question: 'How do I report a problem with a lab or equipment?',
            answer:
                'If you encounter a problem with a lab or equipment, please report it to the lab staff immediately. You can also use the "Contact Us" feature in the app to send a message to the administrator.',
          ),
        ],
      ),
    );
  }
}

class FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const FaqItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                widget.question,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                child: Text(widget.answer),
              ),
          ],
        ),
      ),
    );
  }
}
