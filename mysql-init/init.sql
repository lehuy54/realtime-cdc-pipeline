CREATE DATABASE IF NOT EXISTS inventory;
USE inventory;

-- Customers table
CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  stock INT DEFAULT 0,
  category VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total_amount DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  shipping_address TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Order items table
CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert sample data
INSERT INTO customers (first_name, last_name, email, phone) VALUES
('John', 'Doe', 'john.doe@email.com', '0123456789'),
('Jane', 'Smith', 'jane.smith@email.com', '0987654321'),
('Bob', 'Johnson', 'bob.johnson@email.com', '0555555555');

INSERT INTO products (name, description, price, stock, category) VALUES
('Laptop', 'High-performance laptop', 1200.00, 50, 'Electronics'),
('Mouse', 'Wireless mouse', 25.00, 200, 'Electronics'),
('Keyboard', 'Mechanical keyboard', 80.00, 150, 'Electronics'),
('Monitor', '27-inch 4K monitor', 350.00, 75, 'Electronics'),
('Headphones', 'Noise-canceling headphones', 200.00, 100, 'Electronics');

INSERT INTO orders (customer_id, total_amount, status, shipping_address) VALUES
(1, 1225.00, 'completed', '123 Main St, City A'),
(2, 430.00, 'pending', '456 Oak Ave, City B'),
(3, 80.00, 'shipped', '789 Pine Rd, City C');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1200.00),
(1, 2, 1, 25.00),
(2, 4, 1, 350.00),
(2, 5, 1, 80.00),
(3, 3, 1, 80.00);