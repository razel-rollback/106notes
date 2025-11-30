import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application5/crude_service.dart';
import 'package:flutter_application5/login_page.dart';
import 'package:flutter_application5/favorites_page.dart';

import 'auth_service.dart';

class HomePage extends StatelessWidget {
  final CrudService service = CrudService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Firestore Ponce'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade50,
        actions: [
          IconButton(
            tooltip: 'Show favorites',
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoritesPage()),
            ),
          ),
          IconButton(
            onPressed: () {
              AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.black54),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.blueGrey.shade200),
        onPressed: () => openAddDialog(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No items found. Add some items!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var item = docs[index];

              final data = item.data() as Map<String, dynamic>;
              final imageUrl = data['imageUrl'];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  leading: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                            ),
                          ),
                        ),

                  title: Text(
                    item['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Quantity: ${item['quantity'] ?? 0}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          item['favorite'] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: item['favorite'] == true
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () => service.updateFavorite(
                          item.id,
                          !(item['favorite'] == true),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color.fromARGB(255, 241, 207, 106),
                        ),
                        onPressed: () => openEditDialog(context, item),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 242, 86, 75),
                        ),
                        onPressed: () => confirmDelete(context, item.id),
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

  void openAddDialog(BuildContext context) {
    nameController.clear();
    quantityController.clear();
    File? selectedImagefile;
    String? selectedImageUrl;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              if (selectedImagefile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    selectedImagefile!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Image'),
                onPressed: () async {
                  final pickedFile = await service.pickImageforAddItem();
                  if (pickedFile != null) {
                    setState(() {
                      selectedImagefile = pickedFile.file;
                      selectedImageUrl = pickedFile.url;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              child: const Text('Save'),

              onPressed: () async{
                if (nameController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                await service.addItemWithImage(
                    nameController.text,
                    int.parse(quantityController.text),
                    selectedImageUrl ?? '',
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void openEditDialog(
    BuildContext context,
    QueryDocumentSnapshot<Object?> item,
  ) {
    nameController.text = item['name'] ?? '';
    quantityController.text = item['quantity']?.toString() ?? '0';
    final data = item.data() as Map<String, dynamic>;
    String? selectedImageUrl = data['imageUrl'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                if (selectedImageUrl != null && selectedImageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      selectedImageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: Text(selectedImageUrl != null && selectedImageUrl!.isNotEmpty 
                      ? 'Change Image' 
                      : 'Add Image'),
                  onPressed: () async {
                    final pickedFile = await service.pickImageforAddItem();
                    if (pickedFile != null) {
                      setState(() {
                        selectedImageUrl = pickedFile.url;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Update'),
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  await service.updateItem(
                    item.id,
                    nameController.text,
                    int.parse(quantityController.text),
                    imageUrl: selectedImageUrl,
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => {service.deleteItem(id), Navigator.pop(context)},
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
