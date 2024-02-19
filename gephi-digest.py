#!./venv/bin/python3
import sqlite3
import multiprocessing
import threading
import time
from tqdm import tqdm

def init_thread_data():
    thread_local_data.thread_data = {}

def get_thread_cursor():
    if not hasattr(thread_local_data.thread_data, 'cursor'):
        thread_local_data.thread_data['conn'] = sqlite3.connect('twitter_data.db', timeout=60.0)
        thread_local_data.thread_data['cursor'] = thread_local_data.thread_data['conn'].cursor()
    return thread_local_data.thread_data['cursor']

def insert_nodes_edges(batch_data):
    # Insert nodes and edges SQL statements
    cursor = get_thread_cursor()
    for follower_id, followee_id, follower_name, followee_name, follower_followers_count, followee_followers_count in batch_data:
        while True:
            try:
                cursor.execute("INSERT OR IGNORE INTO Nodes (id, label, node_size) VALUES (?, ?, log(?))", (follower_id, follower_name, follower_followers_count))
                cursor.execute("INSERT OR IGNORE INTO Nodes (id, label, node_size) VALUES (?, ?, log(?))", (followee_id, followee_name, followee_followers_count))
                cursor.execute("INSERT OR IGNORE INTO Edges (source, target, weight) VALUES (?, ?, ?)", (follower_id, followee_id, follower_followers_count))
                break
            except sqlite3.OperationalError as e:
                if "SQLITE_BUSY" not in str(e):
                    print(f"Error inserting nodes and edges: {e}")
                    raise e
                time.sleep(1)  # Wait for a second before retrying
    # Commit after each batch
    cursor.connection.commit()

if __name__ == '__main__':
    # Create a thread-local SQLiteThreadData instance
    thread_local_data = threading.local()
    thread_local_data.thread_data = {}

    # Initialize the thread-local data
    init_thread_data()

    # Create indexes if they don't exist
    cursor = get_thread_cursor()
    cursor.execute("CREATE INDEX IF NOT EXISTS followers_follower_idx ON followers(follower)")
    cursor.execute("CREATE INDEX IF NOT EXISTS followers_followee_idx ON followers(followee)")

    # Create the Nodes and Edges tables if they don't exist
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Nodes (
          id INTEGER PRIMARY KEY,
          label TEXT,
          node_size FLOAT
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Edges (
          id INTEGER PRIMARY KEY,
          source INTEGER,
          target INTEGER,
          weight INTEGER
        )
    """)

    # Get the follower and followee IDs from the followers table
    cursor.execute("SELECT follower, followee, follower_name, followee_name, follower_followers_count, followee_followers_count FROM Followers")
    data = cursor.fetchall()

    # Create a pool of workers
    pool = multiprocessing.Pool(processes=4)

    # Use tqdm to display a progress bar and keep a progress report going on the main management thread
    for batch in tqdm(range(0, len(data), 1000), desc="Processing Users", unit="user"):
        batch_data = data[batch:batch+1000]
        while True:
            try:
                pool.apply(insert_nodes_edges, args=(batch_data,))
                break
            except sqlite3.OperationalError as e:
                if "SQLITE_BUSY" not in str(e):
                    print(f"Error inserting nodes and edges: {e}")
                    raise e
                time.sleep(1)  # Wait for a second before retrying

    # Close the cursor, pool, and the connection to the database
    pool.close()
    pool.join()
    cursor.close()
    cursor.connection.close()

    # Emit a console message when processing ends for a specific unit of work (one of the Users)
    print("All users processed")
