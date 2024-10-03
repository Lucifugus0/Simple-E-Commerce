import 'package:flutter/material.dart';

class ProductList extends StatelessWidget {
  final String category;
  final List<Map<String, String>> cartItems;

  ProductList({required this.category, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> _products = {
      'Baju': [
        {
          'imagePath': 'assets/images/shirt1.png',
          'productName': 'Tanjiro Shirt',
          'price': 'Rp 100.000',
        },
        {
          'imagePath': 'assets/images/shirt2.png',
          'productName': 'Uchiha Clan Shirt',
          'price': 'Rp 100.000',
        },
        {
          'imagePath': 'assets/images/shirt3.png',
          'productName': 'Megumi Fushiguro Shirt',
          'price': 'Rp 100.000',
        },
        {
          'imagePath': 'assets/images/shirt4.png',
          'productName': 'Lil Gojo Shirt',
          'price': 'Rp 100.000',
        },
      ],
      'Elektronik': [
        {
          'imagePath': 'assets/images/electronic1.jpg',
          'productName': 'Gaming Headset',
          'price': 'Rp 300.000',
        },
        {
          'imagePath': 'assets/images/electronic2.jpg',
          'productName': 'Gaming Mouse',
          'price': 'Rp 250.000',
        },
      ],
      'Aksesoris': [
        {
          'imagePath': 'assets/images/keychain2.png',
          'productName': 'Keychain Gojo',
          'price': 'Rp 100.000',
        },
        {
          'imagePath': 'assets/images/keychain.jpg',
          'productName': 'Keychain Naruto',
          'price': 'Rp 50.000',
        },
        {
          'imagePath': 'assets/images/sticker.png',
          'productName': 'Sticker pack One Piece',
          'price': 'Rp 30.000',
        },
        {
          'imagePath': 'assets/images/sticker1.png',
          'productName': 'Sticker pack Naruto',
          'price': 'Rp 30.000',
        },
      ],
    };

    return ListView.builder(
        itemCount: _products[category]?.length ?? 0,
        itemBuilder: (context, index) {
          final product = _products[category]![index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Image.asset(
                product['imagePath']!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              title: Text(product['productName']!),
              subtitle: Text(product['price']!),
              trailing: IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () {
                  cartItems.add(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product['productName']} added to cart')),
                  );
                },
              ),
            ),
          );
          },
        );
    }
}