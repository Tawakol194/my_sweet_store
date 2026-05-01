import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';
import 'product.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (ctx) => AppProvider(),
      child: MaterialApp(
        title: 'Sweet Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: const Color(0xFFFFF5F7), // خلفية وردية ناعمة للمتجر كامل
        ),
        home: const MainNavigation(),
      ),
    ),
  );
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const FavoritesPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket_rounded), label: 'السلة'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<AppProvider>(context).items;
    return Scaffold(
      appBar: AppBar(title: const Text('Sweet 🍰'), centerTitle: true, elevation: 0),
      body: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (ctx, i) => ProductItemCard(product: products[i]),
      ),
    );
  }
}

class ProductItemCard extends StatelessWidget {
  final Product product;
  const ProductItemCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (ctx) => Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(product.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 15),
                Text(product.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink)),
                const SizedBox(height: 10),
                Text(product.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Consumer<AppProvider>(
                  builder: (ctx, p, _) => IconButton(
                    icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 45),
                    onPressed: () => p.toggleFavorite(product),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${product.price}', style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w600, fontSize: 16)),
                  GestureDetector(
                    onTap: () {
                      Provider.of<AppProvider>(context, listen: false).addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة للسلة!'), duration: Duration(seconds: 1)));
                    },
                    child: const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.pinkAccent,
                      child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favItems = Provider.of<AppProvider>(context).favoriteItems;
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: favItems.isEmpty
          ? const Center(child: Text('لا يوجد منتجات في المفضلة'))
          : ListView.builder(
              itemCount: favItems.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(favItems[i].imageUrl)),
                title: Text(favItems[i].title),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => Provider.of<AppProvider>(context, listen: false).toggleFavorite(favItems[i]),
                ),
              ),
            ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('السلة')),
      body: Column(
        children: [
          Expanded(
            child: cart.cartItems.isEmpty
                ? const Center(child: Text('السلة فارغة'))
                : ListView.builder(
                    itemCount: cart.cartItems.length,
                    itemBuilder: (ctx, i) => ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(cart.cartItems[i].imageUrl)),
                      title: Text(cart.cartItems[i].title),
                      subtitle: Text('\$${cart.cartItems[i].price}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => cart.removeFromCart(cart.cartItems[i]),
                      ),
                    ),
                  ),
          ),
          if (cart.cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('\$${cart.totalAmount}', style: const TextStyle(fontSize: 20, color: Colors.pink)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(15)),
                      onPressed: () {
                        cart.clearCart();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت عملية الدفع بنجاح! 🎉')));
                      },
                      child: const Text('إتمام الدفع', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7), 
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.pexels.com/photos/1055271/pexels-photo-1055271.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 160,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundImage: NetworkImage(
                        'https://images.pexels.com/photos/1181682/pexels-photo-1181682.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            
            const Text(
              'Tawakol Albhr',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              label: const Text('تعديل الحساب', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            
            const SizedBox(height: 40),
            
            buildInfoTile(Icons.email_outlined, 'البريد الإلكتروني', 'tawakol@example.com'),
            buildInfoTile(Icons.phone_outlined, 'رقم الهاتف', '+967 7XX XXX XXX'),
            buildInfoTile(Icons.location_on_outlined, 'الموقع', 'اليمن'),
            buildInfoTile(Icons.shopping_bag_outlined, 'تاريخ الإنضمام', 'مايو 2026'),
            const SizedBox(height: 10),
            buildInfoTile(Icons.logout, 'تسجيل الخروج', '', isLogout: true),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildInfoTile(IconData icon, String title, String value, {bool isLogout = false}) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.pinkAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isLogout ? Colors.red : Colors.black87)),
        subtitle: value.isNotEmpty ? Text(value) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }
}