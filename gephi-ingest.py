#!./venv/bin/python3
import os
import json
import sqlite3
from tqdm import tqdm

# Connect to the SQLite database
conn = sqlite3.connect('twitter_data.db')
cursor = conn.cursor()

# Create the tables
cursor.execute('''CREATE TABLE IF NOT EXISTS Users (
                    id INTEGER PRIMARY KEY,
                    username TEXT,
                    displayname TEXT,
                    created TEXT
                )''')
cursor.execute('''CREATE TABLE IF NOT EXISTS Followers (
                    id INTEGER PRIMARY KEY,
                    follower INTEGER,
                    followee INTEGER,
                    follower_name TEXT,
                    followee_name TEXT,
                    follower_followers_count INTEGER,
                    followee_followers_count INTEGER,
                    FOREIGN KEY (follower) REFERENCES Users(id),
                    FOREIGN KEY (followee) REFERENCES Users(id)
                )''')

def process_user_json_file(file_path):
    with open(file_path, 'r') as f:
        for line in f:
            try:
                user = json.loads(line)
                cursor.execute('INSERT OR IGNORE INTO Users (id, username, displayname, created) VALUES (?, ?, ?, ?)', (user['id'], user['username'], user['displayname'], user['created']))
                return user
            except json.JSONDecodeError:
                print(f"Invalid JSON fragment in {file_path}: {line}")

def process_follow_json_file(file_path, user):
    total_lines = sum(1 for line in open(file_path))
    if 'follower' in file_path:
        columns = '(follower, followee, follower_name, followee_name, follower_followers_count, followee_followers_count)'
    else:
        columns = '(followee, follower, followee_name, follower_name, followee_followers_count, follower_followers_count)'

    with open(file_path, 'r') as f:
            for line in tqdm(f, total=total_lines, desc=file_path, unit=' lines'):
                try:
                    follow = json.loads(line)
                    cursor.execute('INSERT OR IGNORE INTO Followers ' + columns + ' VALUES (?, ?, ?, ?, ?, ?)', (user['id'], follow['id'], user['username'], follow['username'], user['followersCount'], follow['followersCount']))
                except json.JSONDecodeError:
                    print(f"Invalid JSON fragment in {file_path}: {line}")

def main(directory):
    if not os.path.isdir(directory):
        print(f"Error: {directory} is not a valid directory.")
        return

    # Process user and follow JSON files in @* subdirectories
    for entry in os.listdir(directory):
        entry_path = os.path.join(directory, entry)
        if os.path.isdir(entry_path) and entry.startswith('@'):
            user = -1
            for file in os.listdir(entry_path):
                file_path = os.path.join(entry_path, file)
                if 'user.json' == file:
                    user = process_user_json_file(file_path)
            for file in os.listdir(entry_path):
                file_path = os.path.join(entry_path, file)
                if ('following.json' == file) or ('followers.json' == file):
                    process_follow_json_file(file_path, user)
    conn.commit()
    cursor.close()
    conn.close()

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python script.py [directory]")
    else:
        main(sys.argv[1])
