# tests/test_fulltext.py

def test_fulltext_product(benchmark, conn):
    """
    Benchmark a full-text search on the 'name' column of the orders table.
    """
    cursor = conn.cursor()
    def query():
        cursor.execute("""
            SELECT product_id
            FROM orders
            WHERE MATCH(name)
            AGAINST('Cotton' IN NATURAL LANGUAGE MODE);
        """)
        return cursor.fetchall()

    # Run the benchmark
    result = benchmark(query)

    # Sanity check: ensure we got a list back
    assert isinstance(result, list)
