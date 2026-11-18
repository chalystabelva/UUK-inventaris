import 'package:flutter/material.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  final List<String> images = const [
    'assets/lab1.png',
    'assets/lab2.png',
    'assets/lab3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: images.length,
        controller: PageController(viewportFraction: 0.95),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Foto tidak ditemukan'));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
