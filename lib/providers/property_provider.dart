import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/database_service.dart';

class PropertyProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<PropertyModel> _properties = [];
  bool _isLoading = false;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  // Filter Sheet Values
  String _filterType = 'All';
  double _filterMaxSqft = 5000.0;
  RangeValues _filterPriceRange = const RangeValues(3000.0, 10000.0);

  List<PropertyModel> get properties => _properties;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  String get filterType => _filterType;
  double get filterMaxSqft => _filterMaxSqft;
  RangeValues get filterPriceRange => _filterPriceRange;

  PropertyProvider() {
    fetchProperties();
  }

  List<PropertyModel> get featuredProperties {
    return _properties.where((p) => p.isFeatured).toList();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    fetchProperties();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchProperties();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterMaxSqft(double sqft) {
    _filterMaxSqft = sqft;
    notifyListeners();
  }

  void setFilterPriceRange(RangeValues range) {
    _filterPriceRange = range;
    notifyListeners();
  }

  void resetFilters() {
    _filterType = 'All';
    _filterMaxSqft = 5000.0;
    _filterPriceRange = const RangeValues(3000.0, 10000.0);
    fetchProperties();
  }

  Future<void> applyFilters() async {
    _selectedCategory = _filterType;
    await fetchProperties(
      minPrice: _filterPriceRange.start,
      maxPrice: _filterPriceRange.end,
      maxSqft: _filterMaxSqft,
    );
  }

  Future<void> fetchProperties({
    double? minPrice,
    double? maxPrice,
    double? maxSqft,
  }) async {
    _isLoading = true;
    notifyListeners();

    _properties = await _db.getProperties(
      category: _selectedCategory,
      searchQuery: _searchQuery,
      minPrice: minPrice ?? (_filterPriceRange.start > 3000 ? _filterPriceRange.start : null),
      maxPrice: maxPrice ?? (_filterPriceRange.end < 10000 ? _filterPriceRange.end : null),
      maxSqft: maxSqft,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addNewProperty(PropertyModel property) async {
    _isLoading = true;
    notifyListeners();

    try {
      String docId = await _db.addProperty(property);
      PropertyModel newProp = PropertyModel(
        id: docId,
        title: property.title,
        type: property.type,
        price: property.price,
        address: property.address,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        kitchens: property.kitchens,
        sqft: property.sqft,
        imageUrl: property.imageUrl,
        isFeatured: property.isFeatured,
        ownerId: property.ownerId,
      );

      _properties.insert(0, newProp);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
