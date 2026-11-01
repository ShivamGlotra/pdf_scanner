import 'package:flutter/material.dart';

import 'package:doc_scanner/models/scan.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.initial});

  final Scan initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(initial.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Scan Details'),
            Text('Title: ${initial.title}'),
            Text('Format: ${initial.format.label}'),
            Text('Pages: ${initial.pageCount}'),
            Text('Created At: ${initial.createdAt}'),
          ],
        ),
      ),
    );
  }
}
