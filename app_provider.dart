import 'package:flutter/material.dart';
import 'product.dart';

class AppProvider with ChangeNotifier {
  final List<Product> _items = [
    Product(
      id: 'p1',
      title: 'كيكة الفراولة',
      price: 22.0,
      description: 'كيكة هشة محشوة بطبقات الكريمة وقطع الفراولة الطازجة',
      imageUrl: 'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg?auto=compress&cs=tinysrgb&w=600',
      bgColor: const Color(0xFFF8E2FE),
    ),
    Product(
      id: 'p2',
      title: 'ماكرون ملون',
      price: 15.0,
      description: 'قطع الماكرون الفرنسية بألوان ونكهات متنوعة تذوب في الفم',
      imageUrl: 'https://images.pexels.com/photos/239578/pexels-photo-239578.jpeg?auto=compress&cs=tinysrgb&w=600',
      bgColor: const Color(0xFFE2EAFB),
    ),
    Product(
      id: 'p3',
      title: 'دونات الشوكولاتة',
      price: 12.0,
      description: 'دونات طازجة مغطاة بأجود أنواع الشوكولاتة الداكنة',
      imageUrl: 'https://images.pexels.com/photos/1191639/pexels-photo-1191639.jpeg?auto=compress&cs=tinysrgb&w=600',
      bgColor: const Color(0xFFFEF3E2),
    ),
    Product(
      id: 'p4',
      title: 'كب كيك فانيليا',
      price: 10.0,
      description: 'كب كيك فانيليا كلاسيكي مزين بكريمة الزبدة الغنية',
      imageUrl: 'https://images.pexels.com/photos/1346215/pexels-photo-1346215.jpeg?auto=compress&cs=tinysrgb&w=600',
      bgColor: const Color(0xFFFFEEEE),
    ),
  ];

  final List<Product> _cartItems = [];

  List<Product> get items => [..._items];
  List<Product> get cartItems => [..._cartItems];
  List<Product> get favoriteItems => _items.where((prod) => prod.isFavorite).toList();

  void toggleFavorite(Product product) {
    product.isFavorite = !product.isFavorite;
    notifyListeners();
  }

  void addToCart(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }


  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double get totalAmount {
    double total = 0.0;
    for (var item in _cartItems) {
      total += item.price;
    }
    return total;
  }

}