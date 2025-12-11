"""
Database connection and utilities for Neon PostgreSQL
"""
import psycopg
from contextlib import contextmanager
from app.config import settings


@contextmanager
def get_db_connection():
    """Get a database connection context manager"""
    conn = psycopg.connect(settings.DATABASE_URL)
    try:
        yield conn
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        conn.close()


def execute_query(query, params=None, fetch_one=False, fetch_all=False):
    """
    Execute a database query

    Args:
        query: SQL query string
        params: Query parameters (tuple or dict)
        fetch_one: Return single row
        fetch_all: Return all rows

    Returns:
        Query result or None
    """
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params or ())

            if fetch_one:
                return cur.fetchone()
            elif fetch_all:
                return cur.fetchall()
            else:
                return None


def execute_query_dict(query, params=None, fetch_one=False, fetch_all=False):
    """
    Execute a query and return results as dictionaries

    Args:
        query: SQL query string
        params: Query parameters
        fetch_one: Return single row as dict
        fetch_all: Return all rows as list of dicts

    Returns:
        Dictionary or list of dictionaries
    """
    with get_db_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(query, params or ())

            if fetch_one:
                return cur.fetchone()
            elif fetch_all:
                return cur.fetchall()
            else:
                return None
