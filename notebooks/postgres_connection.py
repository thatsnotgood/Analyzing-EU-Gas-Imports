from dotenv import load_dotenv
from pathlib import Path
import os
import pandas as pd
import psycopg

# Configure pandas display settings:
pd.set_option('display.max_rows', 50)
pd.set_option('display.min_rows', 10)
pd.set_option('display.expand_frame_repr', True)

# Get the path to the .env file:
dotenv_path = Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path = dotenv_path)

# PostgreSQL database connection:
def db():
    return psycopg.connect(
        host = os.getenv('DB_HOST'),
        port = os.getenv('DB_PORT'),
        user = os.getenv('DB_USER'),
        password = os.getenv('DB_PASSWORD'),
        dbname = os.getenv('DB_NAME')
    )