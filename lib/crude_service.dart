import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class PickedImage{
  final File file;
  final String url;

  PickedImage({required this.file, required this.url});

}




class CrudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');



  final CloudinaryPublic _cloudinary = CloudinaryPublic(
  'dmgaavwzv', 'ds6c6crv',
  cache: false,
);

 final ImagePicker _picker  = ImagePicker();


Future<PickedImage?> pickImageforAddItem() async {
  final pickedfile = await _picker.pickImage(source: ImageSource.gallery);

  if(pickedfile == null) return null;

  final file = File(pickedfile.path);

  final response = await _cloudinary.uploadFile(
    CloudinaryFile.fromFile(
    file.path, 
    resourceType: CloudinaryResourceType.Image,
  ),);

  return PickedImage(file: file, url: response.secureUrl);
}

  Future<void> addItemWithImage(String name, int quantity, String imageUrl) {
    return items.add({
      'name': name,
      'quantity': quantity,
      'favorite': false,
      'imageUrl': imageUrl,
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

  Future<void> updateItem(String id, String name, int quantity, {String? imageUrl}) {
    final Map<String, dynamic> updateData = {
      'name': name,
      'quantity': quantity,
    };
    
    if (imageUrl != null) {
      updateData['imageUrl'] = imageUrl;
    }
    
    return items.doc(id).update(updateData);
  }

  Future<void> updateFavorite(String id, bool favorite) {
    return items.doc(id).update({'favorite': favorite});
  }

  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}
