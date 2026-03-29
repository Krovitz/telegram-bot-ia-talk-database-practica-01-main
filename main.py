"""
Main entry point for the Telegram Bot with Sakila Database and LLM.
"""
from config import setup_api_keys, get_telegram_token, logger
from database.postgres_db import PostgreSQLDatabase
from llm.agent import LLMAgent
from bot.telegram_bot import TelegramBot

def main():
    """Initialize and start the application."""
    try:
        # Set up API keys
        setup_api_keys()

        # Get Telegram bot token
        token = get_telegram_token()

        # Initialize database
        database = PostgreSQLDatabase()
        db = database.get_db()

        # Initialize LLM agent
        llm_agent = LLMAgent(db)

        # Initialize and start Telegram bot
        bot = TelegramBot(token, llm_agent)
        logger.info("Starting Telegram bot...")
        bot.run()

    except Exception as e:
        logger.error(f"Error starting application: {e}")
        raise

if __name__ == '__main__':
    main()