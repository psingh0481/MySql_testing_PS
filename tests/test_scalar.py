import mysql.connector
import pytest

@pytest.fixture(scope="module")
def conn():
    return mysql.connector.connect(
        host='127.0.0.1', port=3306,
        user='root', password='supersecurepassword',
        database='ecommerce'
    )

def test_price_range(benchmark, conn):
    cursor = conn.cursor()
    def query():
        cursor.execute(
            "SELECT COUNT(*) FROM orders WHERE retail_price BETWEEN 50 AND 100;"
        )
        return cursor.fetchone()
    result = benchmark(query)
    assert result[0] >= 0
