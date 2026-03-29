"""
Configuration settings for the application.
"""
import os
import logging
from dotenv import load_dotenv


load_dotenv()  # loads the variables from .env

# Configurar logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# API Keys
def setup_api_keys():
    """Set up required API keys."""
    if not os.environ.get("GOOGLE_API_KEY"):
        raise ValueError("GOOGLE_API_KEY environment variable is not set.")

# Telegram Bot Token
def get_telegram_token():
    """Get the Telegram bot token from environment variables."""
    token = os.getenv('TELEGRAM_BOT_TOKEN')
    if not token:
        raise ValueError("TELEGRAM_BOT_TOKEN environment variable is not set.")
    return token