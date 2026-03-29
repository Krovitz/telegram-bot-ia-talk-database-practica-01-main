"""
Telegram bot module handling message interaction.
"""
import time
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, ContextTypes, filters
from config import logger


class TelegramBot:
    """Class to manage the Telegram bot and handlers."""

    def __init__(self, token, llm_agent):
        """Initialize the Telegram bot with token and LLM agent."""
        self.token = token
        self.llm_agent = llm_agent
        self.application = Application.builder().token(token).build()
        self._setup_handlers()

    def _setup_handlers(self):
        """Set up the handlers for commands and messages."""
        logger.info("Setting up Telegram bot handlers...")
        self.application.add_handler(CommandHandler("start", self.start))
        self.application.add_handler(CommandHandler("help", self.help_command))
        self.application.add_handler(
            MessageHandler(filters.TEXT & ~filters.COMMAND, self.handle_message)
        )
        self.application.add_error_handler(self.error_handler)

    def run(self):
        """Start the bot polling."""
        logger.info("Starting Telegram bot...")
        self.application.run_polling()

    async def start(self, update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
        """Handle the /start command."""
        user = update.effective_user
        await update.message.reply_markdown_v2(
            fr'Hola {user.mention_markdown_v2()}\! Soy un bot que consulta la base de datos\. '
            fr'Pregunta lo que desees\.'
        )

    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
        """Handle the /help command."""
        await update.message.reply_text(
            'Envía una consulta en lenguaje natural y te responderé con datos extraídos de la base de datos sakila.'
        )

    async def handle_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
        """Handle incoming messages and process them with the LLM agent."""
        user_message = update.message.text

        try:
            # Crear agente
            agent_executor = self.llm_agent.create_agent()

            # Mensaje inicial
            processing_message = await update.message.reply_text("Procesando tu solicitud...")

            # Variables para streaming
            full_response = ""
            last_response = ""
            last_update_time = time.time()
            update_interval = 1.0  # segundos

            # Stream de eventos
            events = agent_executor.stream(
                {"messages": [("user", user_message)]},
                stream_mode="values",
            )

            for event in events:
                if "messages" in event and len(event["messages"]) > 0:
                    raw_content = event["messages"][-1].content

                    # 🔥 CONVERSIÓN CORRECTA A TEXTO
                    if isinstance(raw_content, list):
                        current_response = ""
                        for item in raw_content:
                            if isinstance(item, dict) and "text" in item:
                                current_response += item["text"]
                    elif isinstance(raw_content, str):
                        current_response = raw_content
                    else:
                        current_response = str(raw_content)

                    if current_response and current_response != last_response:
                        full_response = current_response

                        current_time = time.time()
                        if (current_time - last_update_time >= update_interval) and (full_response != last_response):
                            try:
                                await context.bot.edit_message_text(
                                    text=full_response,
                                    chat_id=update.effective_chat.id,
                                    message_id=processing_message.message_id
                                )
                                last_response = full_response
                                last_update_time = current_time
                            except Exception as edit_error:
                                if "Message is not modified" not in str(edit_error):
                                    logger.warning(f"Error editing message: {edit_error}")

            # Mensaje final
            if full_response != last_response:
                try:
                    await context.bot.edit_message_text(
                        text=full_response,
                        chat_id=update.effective_chat.id,
                        message_id=processing_message.message_id
                    )
                except Exception as final_edit_error:
                    if "Message is not modified" not in str(final_edit_error):
                        logger.warning(f"Error editing final message: {final_edit_error}")

        except Exception as e:
            logger.error(f"Error processing message: {e}")
            await update.message.reply_text("Lo siento, no pude procesar tu solicitud en este momento.")

    async def error_handler(self, update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
        """Handle errors in the Telegram update."""
        logger.warning(f'Update "{update}" caused error "{context.error}"')