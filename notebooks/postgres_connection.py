from dotenv import load_dotenv
from pathlib import Path
import os
import psycopg

# Get the absolute path to the .env file
dotenv_path = Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path = dotenv_path)

def db():
    return psycopg.connect(
        host = os.getenv('DB_HOST'),
        port = os.getenv('DB_PORT'),
        user = os.getenv('DB_USER'),
        password = os.getenv('DB_PASSWORD'),
        dbname = os.getenv('DB_NAME')
    )