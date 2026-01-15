import pyodbc
import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()

# SQL Server connection
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=LAPTOP-LG4BEQ1J\\SQLEXPRESS;"
    "DATABASE=Finance_RT;"
    "Trusted_Connection=yes;"
)
cursor = conn.cursor()

transaction_types = ["Sale", "Expense", "Refund"]
departments = ["Finance", "Sales", "Operations"]
regions = ["North", "South", "East", "West"]

# Starting point for timestamp (last 30 days)
start_time = datetime.now() - timedelta(days=30)

# Insert 1000 records
for i in range(1000):
    t_type = random.choice(transaction_types)
    amount = round(random.uniform(100, 50000), 2)  # Random amount 100–50000
    dept = random.choice(departments)
    region = random.choice(regions)
    
    # Random timestamp in last 30 days
    random_seconds = random.randint(0, 30*24*60*60)
    transaction_time = start_time + timedelta(seconds=random_seconds)
    
    cursor.execute("""
        INSERT INTO financial_transactions
        (transaction_time, transaction_type, amount, department, region)
        VALUES (?, ?, ?, ?, ?)
    """, transaction_time, t_type, amount, dept, region)

    if (i+1) % 100 == 0:
        print(f"{i+1} records inserted...")  # progress check

conn.commit()
print("✅ 1000 records inserted successfully!")
