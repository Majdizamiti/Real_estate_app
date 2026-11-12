import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';

class DatabaseService {
  static const String databaseUrl = 'https://realestate-d4977-default-rtdb.firebaseio.com/';

  DatabaseReference get _dbRef {
    try {
      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      ).ref();
    } catch (_) {
      return FirebaseDatabase.instance.ref();
    }
  }

  // Save User profile to Firebase Realtime Database (/users/$uid)
  Future<void> saveUserData(UserModel user) async {
    try {
      await _dbRef.child('users').child(user.uid).set(user.toMap());
    } catch (e) {
      // Memory fallback if uninitialized
    }
  }

  // Get User Profile from Firebase Realtime Database
  Future<UserModel?> getUserData(String uid) async {
    try {
      DataSnapshot snapshot = await _dbRef.child('users').child(uid).get();
      if (snapshot.exists && snapshot.value != null) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromMap(data, uid);
      }
    } catch (_) {}
    return null;
  }

  // Save User Preferences in Firebase Realtime Database
  Future<void> updateUserPreferences({
    required String uid,
    required double minBudget,
    required double maxBudget,
    required String preferredLocation,
  }) async {
    try {
      await _dbRef.child('users').child(uid).update({
        'minBudget': minBudget,
        'maxBudget': maxBudget,
        'preferredLocation': preferredLocation,
      });
    } catch (_) {}
  }

  // Add new property listing to Firebase Realtime Database (/properties/$propId)
  Future<String> addProperty(PropertyModel property) async {
    try {
      DatabaseReference newRef = _dbRef.child('properties').push();
      String docId = newRef.key ?? 'prop_${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> data = property.toMap();
      data['id'] = docId;

      await newRef.set(data);
      return docId;
    } catch (_) {
      return property.id;
    }
  }

  // Fetch all properties from Firebase Realtime Database with fallback mock data
  Future<List<PropertyModel>> getProperties({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? maxSqft,
    String? searchQuery,
  }) async {
    List<PropertyModel> results = [];

    try {
      DataSnapshot snapshot = await _dbRef.child('properties').get();
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> propData = Map<String, dynamic>.from(value);
            results.add(PropertyModel.fromMap(propData, key.toString()));
          }
        });
      }
    } catch (_) {}

    // Combine database results with mock properties (avoiding duplicates)
    List<PropertyModel> mockProps = getMockProperties();
    for (var p in results) {
      if (!mockProps.any((m) => m.id == p.id)) {
        mockProps.insert(0, p);
      }
    }

    if (results.isNotEmpty) {
      mockProps = results;
    }

    return _applyLocalFilters(mockProps, category, searchQuery, minPrice, maxPrice, maxSqft);
  }

  List<PropertyModel> _applyLocalFilters(
    List<PropertyModel> list,
    String? category,
    String? query,
    double? minPrice,
    double? maxPrice,
    double? maxSqft,
  ) {
    return list.where((p) {
      if (category != null && category != 'All' && p.type.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query != null && query.isNotEmpty) {
        bool matchesTitle = p.title.toLowerCase().contains(query.toLowerCase());
        bool matchesAddress = p.address.toLowerCase().contains(query.toLowerCase());
        if (!matchesTitle && !matchesAddress) return false;
      }
      if (minPrice != null && p.price < minPrice) return false;
      if (maxPrice != null && p.price > maxPrice) return false;
      if (maxSqft != null && p.sqft > maxSqft) return false;
      return true;
    }).toList();
  }

  static List<PropertyModel> getMockProperties() {
    return [
      PropertyModel(
        id: 'prop_1',
        title: 'Deluxe Apartment',
        type: 'Apartment',
        price: 267000.0,
        address: '2817 Street NY, New York',
        bedrooms: 4,
        bathrooms: 3,
        kitchens: 1,
        sqft: 2000.0,
        imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80',
        isFeatured: true,
        ownerId: 'owner_1',
      ),
      PropertyModel(
        id: 'prop_2',
        title: 'De Apartment',
        type: 'House',
        price: 267000.0,
        address: '2817 Street NY, New York',
        bedrooms: 4,
        bathrooms: 3,
        kitchens: 1,
        sqft: 3000.0,
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
        isFeatured: false,
        ownerId: 'owner_1',
      ),
      PropertyModel(
        id: 'prop_3',
        title: 'Dup Apartment',
        type: 'Apartment',
        price: 357000.0,
        address: '2819 Street NY, New York',
        bedrooms: 3,
        bathrooms: 2,
        kitchens: 1,
        sqft: 2200.0,
        imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
        isFeatured: true,
        ownerId: 'owner_2',
      ),
      PropertyModel(
        id: 'prop_4',
        title: 'Modern Villa',
        type: 'House',
        price: 520000.0,
        address: '104 Ocean View, Los Angeles',
        bedrooms: 5,
        bathrooms: 4,
        kitchens: 2,
        sqft: 4500.0,
        imageUrl: 'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=800&q=80',
        isFeatured: true,
        ownerId: 'owner_2',
      ),
      PropertyModel(
        id: 'prop_5',
        title: 'Executive Office Hub',
        type: 'Office',
        price: 780000.0,
        address: '450 Fifth Ave, Manhattan',
        bedrooms: 0,
        bathrooms: 4,
        kitchens: 1,
        sqft: 6000.0,
        imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80',
        isFeatured: false,
        ownerId: 'owner_3',
      ),
      PropertyModel(
        id: 'prop_6',
        title: 'Green Hill Plot',
        type: 'Land',
        price: 150000.0,
        address: 'Plot 42 Sunset Valley, Austin',
        bedrooms: 0,
        bathrooms: 0,
        kitchens: 0,
        sqft: 10000.0,
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
        isFeatured: false,
        ownerId: 'owner_3',
      ),
    ];
  }
}
