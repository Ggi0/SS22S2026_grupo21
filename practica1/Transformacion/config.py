
import os
from pathlib import Path
from dotenv import load_dotenv


# Rutas del proyecto
BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")
DATA_DIR = BASE_DIR / "data"
LOG_DIR = BASE_DIR / "logs"
LOG_DIR.mkdir(exist_ok=True)

# Archivo(s) fuente. Se admite un solo CSV grande o varios CSV en DATA_DIR
# (el extractor los concatena, cumpliendo con "multiples fuentes heterogeneas").
SOURCE_FILES_PATTERN = "*.csv"

# Conexion a SQL Server
DB_SERVER = os.getenv("DB_SERVER", "localhost")
DB_NAME = os.getenv("DB_NAME", "VuelosBI")
DB_USER = os.getenv("DB_USER", "sa")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_DRIVER = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")


DB_TRUSTED_CONNECTION = os.getenv("DB_TRUSTED_CONNECTION", "false").lower() == "true"


def get_connection_string() -> str:
    """Arma el connection string de SQLAlchemy para SQL Server via pyodbc."""
    if DB_TRUSTED_CONNECTION:
        odbc = (
            f"DRIVER={{{DB_DRIVER}}};SERVER={DB_SERVER};DATABASE={DB_NAME};"
            f"TrustServerCertificate=yes;"        )
    else:
        odbc = (
            f"DRIVER={{{DB_DRIVER}}};"
            f"SERVER={DB_SERVER};"
            f"DATABASE={DB_NAME};"
            f"UID={DB_USER};"
            f"PWD={DB_PASSWORD};"
            f"TrustServerCertificate=yes;"
        )
    from urllib.parse import quote_plus
    return f"mssql+pyodbc:///?odbc_connect={quote_plus(odbc)}"


# Catalogo de referencia de aeropuertos (nombre / ciudad / pais)
# No viene en el CSV fuente, se enriquece aqui. Los codigos que no esten en
# este diccionario igual se cargan (con nombre/ciudad/pais en NULL) para que
# el ETL no falle ante codigos nuevos.
AIRPORT_CATALOG = {
    "MEX": ("Aeropuerto Internacional Benito Juarez", "Ciudad de Mexico", "Mexico"),
    "GUA": ("Aeropuerto Internacional La Aurora", "Ciudad de Guatemala", "Guatemala"),
    "SAP": ("Aeropuerto Internacional Ramon Villeda Morales", "San Pedro Sula", "Honduras"),
    "JFK": ("Aeropuerto Internacional John F. Kennedy", "Nueva York", "Estados Unidos"),
    "PTY": ("Aeropuerto Internacional de Tocumen", "Ciudad de Panama", "Panama"),
    "BOG": ("Aeropuerto Internacional El Dorado", "Bogota", "Colombia"),
    "HAV": ("Aeropuerto Internacional Jose Marti", "La Habana", "Cuba"),
    "MIA": ("Aeropuerto Internacional de Miami", "Miami", "Estados Unidos"),
    "SAL": ("Aeropuerto Internacional Monsenor Oscar Arnulfo Romero", "San Salvador", "El Salvador"),
    "MAD": ("Aeropuerto Adolfo Suarez Madrid-Barajas", "Madrid", "Espana"),
    "LIM": ("Aeropuerto Internacional Jorge Chavez", "Lima", "Peru"),
    "CUN": ("Aeropuerto Internacional de Cancun", "Cancun", "Mexico"),
    "LAX": ("Aeropuerto Internacional de Los Angeles", "Los Angeles", "Estados Unidos"),
    "SJO": ("Aeropuerto Internacional Juan Santamaria", "San Jose", "Costa Rica"),
    "BCN": ("Aeropuerto Josep Tarradellas Barcelona-El Prat", "Barcelona", "Espana"),
}

# Catalogo de nombres canonicos de aerolinea por codigo IATA
# El CSV trae el mismo codigo con el nombre escrito de formas distintas
# (Ryanair / RYANAIR, American Airlines / AMERICAN AIRLINES / aa...),
# por lo que se homologa a un unico nombre canonico por codigo.
AIRLINE_CATALOG = {
    "FR": "Ryanair",
    "AV": "Avianca",
    "IB": "Iberia",
    "DL": "Delta",
    "WN": "Southwest",
    "UA": "United",
    "AA": "American Airlines",
    "AM": "Aeromexico",
    "B6": "JetBlue",
    "CM": "Copa Airlines",
    "BA": "British Airways",
    "LA": "LATAM",
}
