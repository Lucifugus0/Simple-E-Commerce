import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'db_helper.dart';
import 'widget.dart';
import 'package:flutter/services.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    final user = await _dbHelper.loginUser(
      _usernameController.text,
      _passwordController.text,
    );
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username dan Password tidak boleh kosong')),
      );
      return; // Keluar dari fungsi jika ada input yang kosong
    }
    if (user != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => CategoryList(),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WIBU STORE',
          style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white),
        ),
        backgroundColor: Colors.red[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ganti placeholder dengan gambar dari assets
            Container(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text(
                'LOGIN',
                style: TextStyle(
                  color: Colors.white, // Ubah warna teks menjadi putih
                  fontWeight: FontWeight.bold, // Ubah teks menjadi bold
                  fontFamily: 'Poppins', // Gunakan font Poppins
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Ubah warna background menjadi hitam
                padding: EdgeInsets.symmetric(vertical: 16.0,horizontal: 25.0),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              },
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();

  void _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    await _dbHelper.registerUser(
      _usernameController.text,
      _passwordController.text,
    );
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username dan Password tidak boleh kosong')),
      );
      return; // Keluar dari fungsi jika ada input yang kosong
    }else{
      Navigator.of(context).pop(); // Kembali ke halaman login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WIBU STORE',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ganti placeholder dengan gambar dari assets
            Container(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            // Icons placeholders (three icons)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/icon1.png', width: 25, height: 25),
                SizedBox(width: 20),
                Image.asset('assets/images/icon2.png', width: 25, height: 25),
                SizedBox(width: 20),
                Image.asset('assets/images/icon3.png', width: 25, height: 25),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _register,
              child: Text('REGISTER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
              ),
            ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Ubah warna background menjadi hitam
                padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 25.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set timer untuk pindah ke halaman utama setelah 3 detik
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginPage(), // Pindah ke halaman kategorio
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.jpg', // Ganti dengan path logo Anda
              width: MediaQuery.of(context).size.width * 0.7, // Menyesuaikan ukuran logo dengan lebar layar
              height: MediaQuery.of(context).size.height * 0.4, // Menyesuaikan ukuran logo dengan tinggi layar
            ),
            SizedBox(height: 20),
            Text(
              'Welcome To Our Store',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// CategoryList
class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int _selectedIndex = 0;
  List<Map<String, String>> cartItems = []; // Cart items list

  final List<String> categories = ['Baju', 'Elektronik', 'Aksesoris'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WIBU STORE',
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CartPage(cartItems: cartItems),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ProductList(
        category: categories[_selectedIndex], // Pass selected category
        cartItems: cartItems, // Pass the cart items list
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.tshirt),
            label: 'Baju',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.electrical_services),
            label: 'Elektronik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch),
            label: 'Aksesoris',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
// ProfilePage
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        ),
        backgroundColor: Colors.red[800],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/profile.jpg'), // Ganti dengan path foto profil Anda
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Username: bri', // Ganti dengan nama pengguna
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Email: brihrs@Gmail.com', // Ganti dengan email pengguna
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement log out functionality here
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 20.0), // Padding di dalam tombol
                textStyle: TextStyle(
                  fontSize: 16, // Atur ukuran font jika diperlukan
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<Map<String, String>> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item removed from cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart' ,
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        ),
        backgroundColor: Colors.red[800],
      ),
      body: widget.cartItems.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          return ListTile(
            leading: Image.asset(item['imagePath']!, width: 50, height: 50),
            title: Text(item['productName']!),
            subtitle: Text(item['price']!),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeItem(index),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.cartItems.isEmpty
          ? SizedBox.shrink()
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CheckoutPage(
                  cartItems: widget.cartItems,
                ),
              ),
            );
          },
          child: Text('Proceed to Checkout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
      ),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  final List<Map<String, String>> cartItems;

  CheckoutPage({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    for (var item in cartItems) {
      final priceString = item['price']!.replaceAll(RegExp(r'[^0-9]'), '');
      totalPrice += double.parse(priceString);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout',
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        ),
        backgroundColor: Colors.red[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Order',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Row(
                    children: [
                      Image.asset(
                        item['imagePath']!,
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['productName']!,
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              item['price']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Total: Rp ${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PaymentMethodPage(cartItems: cartItems),
                  ),
                );
              },
              child: Text('Proceed to Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 20.0), // Padding di dalam tombol
                textStyle: TextStyle(
                  fontSize: 16, // Atur ukuran font jika diperlukan
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodPage extends StatelessWidget {
  final List<Map<String, String>> cartItems;

  PaymentMethodPage({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Method',
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        ),
        backgroundColor: Colors.red[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('Credit Card'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ConfirmationPage(cartItems: cartItems, paymentMethod: 'Credit Card'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('PayPal'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ConfirmationPage(cartItems: cartItems, paymentMethod: 'PayPal'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.local_atm),
              title: Text('Cash on Delivery'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ConfirmationPage(cartItems: cartItems, paymentMethod: 'Cash on Delivery'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationPage extends StatelessWidget {
  final List<Map<String, String>> cartItems;
  final String paymentMethod;

  ConfirmationPage({required this.cartItems, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    for (var item in cartItems) {
      final priceString = item['price']!.replaceAll(RegExp(r'[^0-9]'), '');
      totalPrice += double.parse(priceString);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Confirmation',
            style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          ),
          backgroundColor: Colors.red[800],
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Confirmation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Payment Method: $paymentMethod',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(
                  'Order Summary:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Row(
                        children: [
                          Image.asset(
                            item['imagePath']!,
                            width: 100,
                            height: 100,
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['productName']!,
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  item['price']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Total: Rp ${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Implement payment confirmation logic here
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment Successful')),
                    );
                  },
                  child: Text('Confirm Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 20.0), // Padding di dalam tombol
                    textStyle: TextStyle(
                      fontSize: 16, // Atur ukuran font jika diperlukan
                    ),
                  ),
                ),
              ],
            ),
            ),
        );
    }
}