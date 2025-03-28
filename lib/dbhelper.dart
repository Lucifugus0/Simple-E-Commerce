import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Product {
  int? id;
  String name;
  String description; // Kolom deskripsi ditambahkan
  double price;
  String imagePath;
  double rating; // Kolom rating ditambahkan

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'rating': rating,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'], // Menambahkan deskripsi
      price: map['price'],
      imagePath: map['imagePath'],
      rating: map['rating'], // Menambahkan rating
    );
  }
}

class User {
  String id;
  String username;
  String password;
  String phone;      // Kolom baru: nomor telepon
  String address;    // Kolom baru: alamat
  String email;      // Kolom baru: email

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.phone,
    required this.address,
    required this.email,
  });
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'food_ordering.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''  
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          imagePath TEXT,
          rating REAL,
          description TEXT
        )
      ''');

      await db.execute('''  
        INSERT INTO products (id,name, description, price, imagePath, rating)
        VALUES (1,'Ramen', 'Karbohidrat dengan Kaldu nikmat', 20000, 'assets/images/ramen1.jpg', 10.1)
      ''');

      await db.execute('''  
        CREATE TABLE users(
          id TEXT PRIMARY KEY,
          username TEXT UNIQUE,
          password TEXT,
          phone TEXT,       
          address TEXT,     
          email TEXT       
        )
      ''');

      await db.execute('''  
        INSERT INTO users ( id,username, password, phone, address, email)
        VALUES (1,'mhs','lulus','+6234567890','banjarwijaya','email@example.com')
      ''');
    });
  }

  Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Product>> fetchProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<void> addUser(User user) async {
    final db = await database;

    final List<Map<String, dynamic>> existingUsers = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [user.username],
    );

    if (existingUsers.isNotEmpty) {
      throw Exception('Username already exists');
    }

    await db.insert('users', {
      'id': user.id,
      'username': user.username,
      'password': user.password,
      'phone': user.phone,
      'address': user.address,
      'email': user.email
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> fetchUser(String username, String password) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User(
        id: maps[0]['id'],
        username: maps[0]['username'],
        password: maps[0]['password'],
        phone: maps[0]['phone'],        // Mengambil nomor telepon
        address: maps[0]['address'],    // Mengambil alamat
        email: maps[0]['email'],        // Mengambil email
      );
    }
    return null;
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Fungsi untuk menambahkan produk
  Future<void> addProduct1(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fungsi untuk memperbarui produk
  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<List<User>> fetchAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User(
      id: maps[i]['id'],
      username: maps[i]['username'],
      password: maps[i]['password'],
      phone: maps[i]['phone'],        // Mengambil nomor telepon
      address: maps[i]['address'],    // Mengambil alamat
      email: maps[i]['email'],        // Mengambil email
    ));
  }

  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      {
        'username': user.username,
        'password': user.password,
        'phone': user.phone,          // Memperbarui nomor telepon
        'address': user.address,      // Memperbarui alamat
        'email': user.email           // Memperbarui email
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
