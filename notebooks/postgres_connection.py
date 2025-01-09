import os
from pathlib import Path

import pandas as pd
import psycopg
from psycopg import OperationalError, ProgrammingError
from dotenv import load_dotenv

# Configure pandas display settings:
pd.set_option('display.max_rows', 50)
pd.set_option('display.min_rows', 10)
pd.set_option('display.expand_frame_repr', True)

# Get the path of the .env file:
dotenv_path = Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path = dotenv_path)

# PostgreSQL database connection:
def db():
    try:
        return psycopg.connect(
            host = os.getenv('DB_HOST'),
            port = os.getenv('DB_PORT'),
            user = os.getenv('DB_USER'),
            password = os.getenv('DB_PASSWORD'),
            dbname = os.getenv('DB_NAME')
        )
    except OperationalError as e:
        print(f"Unable to connect to the database: {e}")
        raise
    except ProgrammingError as e:
        print(f"An error occurred with the execution of the SQL query: {e}")
        raise
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        raise