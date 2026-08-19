from sqlalchemy import create_engine

from config import get_connection_string

engine = create_engine(get_connection_string())

with engine.connect() as conn:
    print("Conectado correctamente")