import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application5/crude_service.dart';

class FavoritesPage extends StatelessWidget {
  final CrudService service = CrudService();

  FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.blueGrey.shade50,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getItems(favoriteOnly: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No favorite items yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var item = docs[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Quantity: ${item['quantity']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          item['favorite'] == true ? Icons.favorite : Icons.favorite_border,
                          color: item['favorite'] == true ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => service.updateFavorite(item.id, !(item['favorite'] == true)),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color.fromARGB(255, 241, 207, 106),
                        ),
                        onPressed: () {
                          // Reuse HomePage dialogs by pushing a temporary route that
                          // can call the same dialog logic if needed. For simplicity,
                          // open a simple edit dialog here.
                          _openEditDialog(context, item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 242, 86, 75),
                        ),
                        onPressed: () => _confirmDelete(context, item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openEditDialog(BuildContext context, QueryDocumentSnapshot<Object?> item) {
    final nameController = TextEditingController(text: item['name']);
    final quantityController = TextEditingController(text: item['quantity'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                service.updateItem(
                  item.id,
                  nameController.text,
                  int.parse(quantityController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this favorite item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              service.deleteItem(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
