import os
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool
from langchain_community.utilities.sql_database import SQLDatabase
from config import logger


class PostgreSQLDatabase:
    """Clase para gestionar la conexión a la base de datos Chinook en PostgreSQL,
    cargando los argumentos desde variables de entorno."""

    def __init__(self, host=None, port=None, database=None, username=None, password=None):
        """
        Inicializa la conexión a la base de datos usando valores predeterminados o desde env.

        Args:
            host: Host del servidor PostgreSQL (por defecto se lee de DB_HOST o 'localhost')
            port: Puerto del servidor PostgreSQL (por defecto se lee de DB_PORT o '5432')
            database: Nombre de la base de datos (por defecto se lee de DB_NAME o 'chinook')
            username: Usuario de PostgreSQL (por defecto se lee de DB_USER o 'postgres')
            password: Contraseña de PostgreSQL (por defecto se lee de DB_PASSWORD o 'postgres')
        """
        self.db_config = {
            "host": host or os.getenv("DB_HOST", "postgres"),
            "port": port or os.getenv("DB_PORT", "5432"),
            "database": database or os.getenv("POSTGRES_DB", "postgres"),
            "user": username or os.getenv("POSTGRES_USER", "postgres"),
            "password": password or os.getenv("POSTGRES_PASSWORD", "postgres")
        }

        self.engine = self._get_engine_for_chinook_db()
        self.db = SQLDatabase(self.engine)

    def _get_engine_for_chinook_db(self):
        """Crea un engine para conectar a la base de datos PostgreSQL."""
        logger.info("Setting up connection to Chinook PostgreSQL database...")
        conn_string = (
            f"postgresql+psycopg2://{self.db_config['user']}:{self.db_config['password']}"
            f"@{self.db_config['host']}:{self.db_config['port']}/{self.db_config['database']}"
        )
        try:
            engine = create_engine(
                conn_string,
                poolclass=QueuePool,
                pool_size=5,
                max_overflow=10,
                pool_timeout=30,
                pool_recycle=1800
            )
            # Probar la conexión
            with engine.connect() as conn:
                logger.info("Connection test successful")
            logger.info("Connection to Chinook PostgreSQL database established")
            return engine
        except Exception as e:
            logger.error("Failed to connect to PostgreSQL database", exc_info=e)
            raise

    def get_db(self):
        """Retorna la instancia de SQLDatabase."""
        return self.db
