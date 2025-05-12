import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicpa/src/features/access_card/presentation/widgets/card_widget.dart';

class CardListScreen extends ConsumerWidget{

  const CardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
        
            children: <Widget>[              
              CardWidget(
              name: "Company Access", 
              domain: "example-corp.com", 
              cardColor: Colors.red.shade400,
            ),
            const SizedBox(height: 20),
             CardWidget(
              name: "Event Specific Access", 
              domain: "example-event.com", 
              cardColor: Colors.blue.shade400,
            ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        tooltip: 'Add Card',
        child: const Icon(Icons.add),
      ),
    );
  }
}