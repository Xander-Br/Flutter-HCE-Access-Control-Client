import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sicpa/src/core/router/app_routes.dart';
import 'package:sicpa/src/features/access_card/models/totp_model.dart';
import 'package:sicpa/src/features/access_card/presentation/widgets/card_widget.dart';
import 'package:sicpa/src/features/access_card/presentation/providers/totp_list_notifier.dart'; 



class CardListScreen extends ConsumerWidget {
  const CardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTotpList = ref.watch(totpListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(totpListProvider.notifier).refresh();
            },
            tooltip: 'Refresh List',
          ),
        ],
      ),
      body: asyncTotpList.when(
        data: (totpItems) {
          if (totpItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_sim_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No Access Cards Found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the "+" button to add your first card.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                   ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Card'),
                    onPressed: () {
                       GoRouter.of(context).push(AppRoutes.addCard).then((_) {
                       
                        ref.read(totpListProvider.notifier).refresh();
                      });
                    },
                  )
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(totpListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: totpItems.length,
              itemBuilder: (context, index) {
                final item = totpItems[index];
                return CardWidget(
                  name: item.accountName.isNotEmpty ? item.accountName : (item.issuer.isNotEmpty ? item.issuer : "Unnamed Account"),
                  domain: item.accountName.isNotEmpty && item.issuer.isNotEmpty ? item.issuer : "",
                  cardColor: generateCardColorForItem(item, shadeValue: Theme.of(context).brightness == Brightness.dark ? 500 : 400),
                  onTap: () {
                  
                  },
                  onLongPress: () {
                    
                  }
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 16),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text('Error loading cards: $error', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  ref.read(totpListProvider.notifier).refresh();
                },
                child: const Text('Try Again'),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          GoRouter.of(context).push(AppRoutes.addCard).then((_) {
            
            ref.read(totpListProvider.notifier).refresh();
          });
        },
        tooltip: 'Add New Card',
        icon: const Icon(Icons.add),
        label: const Text("Add Card"),
      ),
    );
  }
}


Color generateCardColorForItem(TotpModel item, {int shadeValue = 400}) {
  final List<MaterialColor> colorPalettes = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.orange, 
    Colors.deepOrange, Colors.brown, Colors.blueGrey, Colors.amber,
  ];

  final int hashCode = item.id.hashCode;
  final color = colorPalettes[hashCode.abs() % colorPalettes.length];
  
  switch (shadeValue) {
    case 100: return color.shade100;
    case 200: return color.shade200;
    case 300: return color.shade300;
    case 400: return color.shade400;
    case 500: return color.shade500;
    case 600: return color.shade600;
    case 700: return color.shade700;
    case 800: return color.shade800;
    case 900: return color.shade900;
    default: return color.shade400; // Default shade
  }
}