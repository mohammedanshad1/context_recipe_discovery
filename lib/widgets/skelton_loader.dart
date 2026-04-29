import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                          width: double.infinity,
                          child: ColoredBox(color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          height: 16,
                          width: 120,
                          child: ColoredBox(color: Colors.white),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          height: 14,
                          width: double.infinity,
                          child: ColoredBox(color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        SizedBox(
                          height: 14,
                          width: 200,
                          child: ColoredBox(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}