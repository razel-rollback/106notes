import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(String name, int quantity) {
    return items.add({
      'name': name,
      'quantity': quantity,
      'favorite': false,
      'created_At': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getItems({bool favoriteOnly = false}) {
  Query query = items;

  if (favoriteOnly) {
    // No orderBy here, so no composite index needed
    query = query.where('favorite', isEqualTo: true);
  } else {
    // Only order when showing all
    query = query.orderBy('created_At', descending: true);
  }

  return query.snapshots();
}

  Future<void> updateItem(String id, String name, int quantity) {
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  Future<void> updateFavorite(String id, bool favorite) {
    return items.doc(id).update({'favorite': favorite});
  }

  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}
