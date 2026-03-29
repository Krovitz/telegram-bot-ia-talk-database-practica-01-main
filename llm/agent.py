"""
LLM and agent setup module.
"""
import os
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_community.agent_toolkits.sql.toolkit import SQLDatabaseToolkit
from langgraph.prebuilt import create_react_agent
from config import logger


class LLMAgent:
    """Class to manage the LLM agent and tools."""

    def __init__(self, db):
        """Initialize the LLM and toolkit with the given database."""
        logger.info("Setting up LLM agent...")
        self.db = db

        # Google Gemini model
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-2.5-flash",
            temperature=0,
            google_api_key=os.getenv("GOOGLE_API_KEY")
        )

        self.toolkit = SQLDatabaseToolkit(db=db, llm=self.llm)

        # Minimalist SQL Agent System Prompt to avoid tool-calling conflicts
        system_prompt_str = (
            "You are an expert SQL assistant. Your goal is to help users query a {dialect} database. "
            "Always limit your query to {top_k} results unless the user asks for more."
        )
        dialect = os.getenv("DB_DIALECT", "SQLite")
        self.system_message = system_prompt_str.format(dialect=dialect, top_k=5)

        logger.info("LLM agent setup complete")

    def create_agent(self):
        """Create and return a reactive agent with the toolkit."""
        return create_react_agent(
            self.llm,
            self.toolkit.get_tools(),
            prompt=self.system_message
        )