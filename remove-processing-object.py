import sqlite3
import json

def clean_processing_status(db_path):
    try:
        # Connect to the database
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        # 1. Fetch the rows. We need the primary key (assuming 'id') to update specific rows.
        cursor.execute("SELECT id, documents, info_tables FROM conversation")
        rows = cursor.fetchall()

        for row_id, docs_str, info_str in rows:
            # Helper to filter the JSON arrays
            def filter_json(json_str):
                if not json_str:
                    return json_str
                try:
                    data = json.loads(json_str)
                    if isinstance(data, list):
                        # Keep objects ONLY if status is NOT "PROCESSING"
                        cleaned_data = [obj for obj in data if obj.get("status") != "PROCESSING"]
                        return json.dumps(cleaned_data)
                except json.JSONDecodeError:
                    return json_str
                return json_str

            new_docs = filter_json(docs_str)
            new_info = filter_json(info_str)

            # 2. Update the row if changes were made
            cursor.execute(
                "UPDATE conversation SET documents = ?, info_tables = ? WHERE id = ?",
                (new_docs, new_info, row_id)
            )

        conn.commit()
        print(f"Successfully scrubbed 'PROCESSING' entries from {len(rows)} rows.")

    except sqlite3.Error as e:
        print(f"Database error: {e}")
    finally:
        if conn:
            conn.close()

# Run the script
clean_processing_status('your_database.db')
