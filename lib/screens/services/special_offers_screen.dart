import 'package:flutter/material.dart';
import 'package:empleame/data/mock_data.dart';
import 'package:empleame/widgets/home/offer_card.dart';

class SpecialOffersScreen extends StatelessWidget {
  const SpecialOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers'),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        itemCount: specialOffers.length,
        itemBuilder: (context, index) {
          final offer = specialOffers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: OfferCard(
              discount: offer.discount,
              title: offer.title,
              description: offer.description,
            ),
          );
        },
      ),
    );
  }
}
