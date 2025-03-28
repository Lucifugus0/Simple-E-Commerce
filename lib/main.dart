import 'package:flutter/material.dart';
import 'dbhelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FoodOrderingApp());
}

class FoodOrderingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ramenkuy',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for Logo
            Container(
              margin: EdgeInsets.only(bottom: 40.0),
              child: Text(
                'Ramen Kuy',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Username Input
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(fontSize: 18),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Password Input
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: 18),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
            ),

            SizedBox(height: 20),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),

            SizedBox(height: 40),
            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Login', style: TextStyle(fontSize: 20)),
            ),
            SizedBox(height: 20),
            // Register Button
            InkWell(
              onTap: () {
                setState(() {
                  _errorMessage = null; // Reset error message when navigating to Register page
                });
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Text('Dont Have Account?', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in both fields';
        _isLoading = false;
      });
      return;
    }

    final db = DBHelper();
    try {
      // Check if the username and password are for the admin
      if (usernameController.text == 'admin' && passwordController.text == 'admin') {
        // Navigate to AdminPage if the credentials match "admin"
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPage()));
      } else {
        // If not admin, check user in the database
        final user = await db.fetchUser(usernameController.text, passwordController.text);

        if (user != null) {
          // If user is found, save username to SharedPreferences and navigate to HomePage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', usernameController.text);
          await prefs.setString('phone', user.phone);  // Simpan phone
          await prefs.setString('address', user.address);  // Simpan address
          await prefs.setString('email', user.email);  // Simpan email
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          // Show error if user credentials are invalid
          setState(() {
            _errorMessage = 'Invalid username or password';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while logging in';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imagePathController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  // Controller untuk user
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController(); // Controller untuk nomor telepon
  final TextEditingController _addressController = TextEditingController(); // Controller untuk alamat
  final TextEditingController _emailController = TextEditingController(); // Controller untuk email

  Future<void> _addUser() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String phoneNumber = _phoneNumberController.text; // Ambil nomor telepon
    final String address = _addressController.text; // Ambil alamat
    final String email = _emailController.text; // Ambil email

    if (username.isEmpty || password.isEmpty || phoneNumber.isEmpty || address.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field pengguna harus diisi!')),
      );
      return;
    }

    User newUser = User(
      id: DateTime.now().toString(),
      username: username,
      password: password,
      phone: phoneNumber,
      address: address,
      email: email,
    );

    try {
      await DBHelper().addUser(newUser);
      // Clear the text fields
      _usernameController.clear();
      _passwordController.clear();
      _phoneNumberController.clear(); // Clear nomor telepon
      _addressController.clear(); // Clear alamat
      _emailController.clear(); // Clear email

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengguna berhasil ditambahkan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan pengguna: ${e.toString()}')),
      );
    }
  }

  Future<void> _addProduct() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final double price = double.tryParse(_priceController.text) ?? 0;
    final String imagePath = _imagePathController.text;
    final double rating = double.tryParse(_ratingController.text) ?? 0;

    if (name.isEmpty || description.isEmpty || price <= 0 || imagePath.isEmpty || rating <= 1 || rating > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field produk harus diisi dengan benar!')),
      );
      return;
    }
    try {
      await DBHelper().addProduct(Product(
        name: name,
        description: description,
        price: price,
        imagePath: imagePath,
        rating: rating,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan pengguna: ${e.toString()}')),
      );
    }

    // Kosongkan field setelah penambahan produk
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _imagePathController.clear();
    _ratingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Form Add Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // Form untuk produk
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi Produk'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Harga Produk'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _imagePathController,
                decoration: InputDecoration(labelText: 'Path Gambar (assets/images/)'),
              ),
              TextField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating Produk (1-10)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Tambah Produk'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProductPage()),
                  );
                },
                child: Text('Lihat Daftar Produk'),
              ),
              SizedBox(height: 40),

              // Form untuk user
              Text('Form Add User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _phoneNumberController, // Field untuk nomor telepon
                decoration: InputDecoration(labelText: 'Nomor Telepon'),
              ),
              TextField(
                controller: _addressController, // Field untuk alamat
                decoration: InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: _emailController, // Field untuk email
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addUser,
                child: Text('Tambah Pengguna'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserPage()),
                  );
                },
                child: Text('Lihat Daftar User'),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // Kontrol untuk telepon
  final TextEditingController _addressController = TextEditingController(); // Kontrol untuk alamat
  final TextEditingController _emailController = TextEditingController(); // Kontrol untuk email

  List<User> _users = [];
  String? _editingUserId; // Melacak ID pengguna yang sedang diedit

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await DBHelper().fetchAllUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _deleteUser(String userId) async {
    await DBHelper().deleteUser(userId);
    _fetchUsers(); // Refresh daftar pengguna setelah dihapus
  }

  void _startEditUser(User user) {
    setState(() {
      _editingUserId = user.id; // Simpan ID pengguna yang sedang diedit
      _usernameController.text = user.username;
      _passwordController.text = user.password;
      _phoneController.text = user.phone; // Isi field telepon
      _addressController.text = user.address; // Isi field alamat
      _emailController.text = user.email; // Isi field email
    });
  }

  Future<void> _editUser() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String phone = _phoneController.text;
    final String address = _addressController.text;
    final String email = _emailController.text;

    if (username.isEmpty || password.isEmpty || phone.isEmpty || address.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua kolom harus diisi!')),
      );
      return;
    }

    User updatedUser = User(
      id: _editingUserId!,
      username: username,
      password: password,
      phone: phone,
      address: address,
      email: email,
    );

    await DBHelper().updateUser(updatedUser);
    _usernameController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _addressController.clear();
    _emailController.clear();
    _fetchUsers(); // Refresh daftar pengguna setelah diupdate

    setState(() {
      _editingUserId = null; // Keluar dari mode edit
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengguna berhasil diupdate!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPage())); // Navigasi kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true, // Menyembunyikan teks password
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'), // Kolom baru untuk telepon
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'), // Kolom baru untuk alamat
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'), // Kolom baru untuk email
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editingUserId != null ? _editUser : null, // Tombol aktif jika dalam mode edit
              child: Text('Simpan Perubahan'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text('Id: ${user.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username: ${user.username}'),
                        Text('Password: ${user.password}'),
                        Text('Phone: ${user.phone}'), // Menampilkan telepon
                        Text('Address: ${user.address}'), // Menampilkan alamat
                        Text('Email: ${user.email}'), // Menampilkan email
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _startEditUser(user); // Mulai mode edit dengan ID user
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteUser(user.id); // Hapus pengguna berdasarkan ID
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> _products = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // Controller untuk deskripsi
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imagePathController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController(); // Controller untuk rating
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DBHelper().fetchProducts();
    setState(() {
      _products = products;
    });
  }

  Future<void> _deleteProduct(int id) async {
    await DBHelper().deleteProduct(id);
    _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produk berhasil dihapus')),
    );
  }

  Future<void> _addOrUpdateProduct() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text; // Ambil deskripsi
    final double price = double.tryParse(_priceController.text) ?? 0;
    final String imagePath = _imagePathController.text;
    final double rating = double.tryParse(_ratingController.text) ?? 0; // Ambil rating

    if (name.isEmpty || description.isEmpty || price <= 0 || imagePath.isEmpty || rating <= 1 || rating >10 ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi dengan benar!')),
      );
      return;
    }

    Product product = Product(
      id: _selectedProductId,
      name: name,
      description: description, // Sertakan deskripsi
      price: price,
      imagePath: imagePath,
      rating: rating, // Sertakan rating
    );

    if (_selectedProductId == null) {
      // Create new product
      await DBHelper().addProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );
    } else {
      // Update existing product
      await DBHelper().updateProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil diperbarui!')),
      );
    }

    // Clear input fields and reset selection
    _nameController.clear();
    _descriptionController.clear(); // Clear deskripsi
    _priceController.clear();
    _imagePathController.clear();
    _ratingController.clear(); // Clear rating
    _selectedProductId = null;
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: _descriptionController, // Field deskripsi
              decoration: InputDecoration(labelText: 'Deskripsi Produk'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Harga Produk'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imagePathController,
              decoration: InputDecoration(labelText: 'Path Gambar (assets/images/)'),
            ),
            TextField(
              controller: _ratingController, // Field rating
              decoration: InputDecoration(labelText: 'Rating Produk (0-10)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addOrUpdateProduct,
              child: Text('Update Produk'),
            ),
            SizedBox(height: 20),
            _products.isEmpty
                ? Center(child: Text('Tidak ada produk'))
                : Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    margin: EdgeInsets.all(10.0),
                    child: ListTile(
                      leading: Image.asset(
                        product.imagePath,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product.name),
                      subtitle: Text('Harga : Rp.${product.price.toString()} \nRating : ${product.rating.toString()} \nDeskripsi :  ${product.description} '), // Menampilkan rating
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Load product details for editing
                              _nameController.text = product.name;
                              _descriptionController.text = product.description; // Load deskripsi untuk diedit
                              _priceController.text = product.price.toString();
                              _imagePathController.text = product.imagePath;
                              _ratingController.text = product.rating.toString(); // Load rating untuk diedit
                              _selectedProductId = product.id;
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Konfirmasi penghapusan produk
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Konfirmasi'),
                                    content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Batal'),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Tutup dialog
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Hapus'),
                                        onPressed: () {
                                          _deleteProduct(product.id!); // Hapus produk
                                          Navigator.of(context).pop(); // Tutup dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(); // Kontrol untuk telepon
  final TextEditingController addressController = TextEditingController(); // Kontrol untuk alamat
  final TextEditingController emailController = TextEditingController(); // Kontrol untuk email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for Logo
            Container(
              margin: EdgeInsets.only(bottom: 40.0),
              child: Text(
                'Ramen Kuy',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Username Input
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(fontSize: 18),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Password Input
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: 18),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Phone Input
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(fontSize: 18),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Address Input
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: TextStyle(fontSize: 18),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Email Input
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: 18),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),

            SizedBox(height: 40),

            // Register Button
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty ||
                    passwordController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    addressController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                final userId = usernameController.text;
                final dbHelper = DBHelper();

                try {
                  // Attempt to add user, if username already exists, an exception will be thrown
                  await dbHelper.addUser(User(
                    id: userId,
                    username: usernameController.text,
                    password: passwordController.text,
                    phone: phoneController.text, // Tambahkan telepon
                    address: addressController.text, // Tambahkan alamat
                    email: emailController.text, // Tambahkan email
                  ));
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginPage())); // Go back to the login page
                } catch (e) {
                  // Show error message if username already exists
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Username already exists')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
              child: Text('Register', style: TextStyle(fontSize: 20)),
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('Need to Login?', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  bool _isNavigating = false; // Untuk menghindari navigasi ganda

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await DBHelper().fetchProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      // Handle error loading products
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ramenkuy'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              if (!_isNavigating) {
                _isNavigating = true;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                ).then((_) {
                  _isNavigating = false; // Reset flag setelah navigasi selesai
                });
              }
            },
          ),
          // Tombol View Profile dengan Icon
          IconButton(
            icon: Icon(Icons.person), // Ikon untuk Profile
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          // Tombol Logout dengan Icon
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Menu', // Judul tetap sama
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: EdgeInsets.all(16.0),
              children: _buildItems(), // Menampilkan semua produk
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    return _products.map((product) {
      return GestureDetector(
        onTap: () {
          if (!_isNavigating) {
            _isNavigating = true; // Set flag saat mulai navigasi
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailPage(
                  imagePath: product.imagePath,
                  foodName: product.name,
                  foodPrice: product.price.toInt(),
                  foodDescription: product.description,
                  foodRating: product.rating, // Menggunakan deskripsi jika ada
                ),
              ),
            ).then((_) {
              _isNavigating = false; // Reset flag setelah navigasi selesai
            });
          }
        },
        child: Container(
          margin: const EdgeInsets.all(5.0),
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  product.imagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Nama produk
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    // Harga produk
                    Text(
                      'Rp.${product.price.toString()}',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? phone;
  String? address;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      phone = prefs.getString('phone');
      address = prefs.getString('address');
      email = prefs.getString('email');

      // Debugging: Cetak data untuk memeriksa apakah sudah diambil dengan benar
      print('Username: $username');
      print('Phone: $phone');
      print('Address: $address');
      print('Email: $email');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Menghapus data pengguna di SharedPreferences

              // Hapus semua halaman sebelumnya setelah logout
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,  // Hapus semua halaman dari stack
              );
            },
          ),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile.jpg'), // Ganti dengan path gambar yang sesuai
            ),
            SizedBox(height: 16),
            Text(
              'Name: ${username ?? 'Not Available'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Phone: ${phone ?? 'Not Available'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Address: ${address ?? 'Not Available'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${email ?? 'Not Available'}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}


class FoodDetailPage extends StatelessWidget {
  final String imagePath;
  final String foodName;
  final int foodPrice;
  final String foodDescription;
  final double foodRating; // Properti untuk rating

  FoodDetailPage({
    required this.imagePath,
    required this.foodName,
    required this.foodPrice,
    required this.foodDescription,
    required this.foodRating, // Inisialisasi rating
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(foodName),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(imagePath),
            SizedBox(height: 16),
            Text(
              foodName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Rp.${foodPrice.toString()}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              foodDescription, // Menampilkan deskripsi makanan
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.yellow),
                SizedBox(width: 4),
                Text(
                  foodRating.toString(), // Menampilkan rating numerik
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 25),
            // Tombol "Add to Cart"
            ElevatedButton(
              onPressed: () {
                // Fungsi untuk menambahkan ke keranjang
                CartItem? existingItem = cart.firstWhere(
                      (item) => item.name == foodName,
                  orElse: () => CartItem(name: '', price: 0, imagePath: ''),
                );

                if (existingItem.name == '') {
                  // Jika item belum ada di keranjang, tambahkan
                  cart.add(CartItem(name: foodName, price: foodPrice, imagePath: imagePath));
                } else {
                  // Jika item sudah ada, tambahkan jumlah
                  existingItem.quantity++;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$foodName added to cart')),
                );
              },
              child: Text('Add to Cart', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final String name;
  final String imagePath; // Menyimpan path gambar
  final int price;
  int quantity;

  CartItem({
    required this.name,
    required this.imagePath,
    required this.price,
    this.quantity = 1,
  });
}

List<CartItem> cart = [];

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String itemName = '';
  String itemImage = '';
  int itemPrice = 0; // Anda bisa menyesuaikan ini jika harga bervariasi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: cart.isEmpty
          ? Center(
        child: Text(
          'Cart is empty',
          style: TextStyle(fontSize: 24),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final cartItem = cart[index];
                return ListTile(
                  leading: Image.asset(
                    cartItem.imagePath,
                    width: 50,
                    height: 50,
                  ),
                  title: Text(cartItem.name),
                  subtitle: Text('Price per item: Rp.${cartItem.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (cartItem.quantity > 1) {
                              cartItem.quantity--;
                            } else {
                              cart.removeAt(index);
                            }
                          });
                        },
                      ),
                      Text('${cartItem.quantity}', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            cartItem.quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Input untuk menambahkan item ke keranjang
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CheckoutPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Tombol lebar penuh
              ),
              child: Text('Proceed to Checkout', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    int totalAmount = cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display total price
            Text(
              'Total Amount: Rp.${totalAmount.toString()}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Payment Method
            Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 18),
            ),
            ListTile(
              title: const Text('Credit'),
              leading: Radio<String>(
                value: 'Credit',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Debit'),
              leading: Radio<String>(
                value: 'Debit',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ),

            SizedBox(height: 20),

            // Confirm Payment Button
            ElevatedButton(
              onPressed: _selectedPaymentMethod == null
                  ? null
                  : () {
                _confirmPayment(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Full-width button
              ),
              child: Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Confirmation'),
          content: Text(
              'You have selected $_selectedPaymentMethod payment method.\n\nProceed with the payment?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage())); // Close dialog
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage())); // Close dialog
                _completePayment(context); // Complete payment
              },
            ),
          ],
        );
      },
    );
  }

  void _completePayment(BuildContext context) {
    // Clear cart and show success message
    setState(() {
      cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment successful!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
    );// Go back to previous page after successful payment
  }
}

class PaymentSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Successful'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Thank you for your purchase.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                      (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              child: Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}