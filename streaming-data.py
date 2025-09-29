# save as streaming-data.py
import mysql.connector
import random
import time
from faker import Faker

fake = Faker()

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="huymysql",
    database="inventory"
)
cursor = conn.cursor()

while True:
    # Random operation
    op = random.choice(['insert_customer', 'insert_order', 'update_product'])
    
    if op == 'insert_customer':
        sql = """INSERT INTO customers (first_name, last_name, email, phone) 
                 VALUES (%s, %s, %s, %s)"""
        cursor.execute(sql, (fake.first_name(), fake.last_name(), 
                            fake.email(), fake.phone_number()))
        print(f"Inserted customer")
    
    elif op == 'insert_order':
        cursor.execute("SELECT id FROM customers ORDER BY RAND() LIMIT 1")
        customer_id = cursor.fetchone()[0]
        sql = """INSERT INTO orders (customer_id, total_amount, status) 
                 VALUES (%s, %s, %s)"""
        cursor.execute(sql, (customer_id, round(random.uniform(10, 1000), 2),
                            random.choice(['pending', 'completed', 'shipped'])))
        print(f"Inserted order")
    
    elif op == 'update_product':
        cursor.execute("SELECT id FROM products ORDER BY RAND() LIMIT 1")
        product_id = cursor.fetchone()[0]
        new_stock = random.randint(0, 500)
        sql = "UPDATE products SET stock = %s WHERE id = %s"
        cursor.execute(sql, (new_stock, product_id))
        print(f"Updated product stock")
    
    conn.commit()
    time.sleep(random.uniform(1, 5))  # Random delay 1-5 seconds