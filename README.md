# Kingdom of Choices

A village-based RPG with AI-powered NPC interactions, quest system, and relationship building.

![Kingdom of Choices](icon.svg)

## About

Kingdom of Choices is a cozy village game where players interact with NPCs, complete quests, and build relationships. The game features AI-powered dialogue that responds dynamically based on the player's relationships with NPCs and the context of ongoing quests.

## Game Rules

The goal of the game is to build strong relationships with the NPC characters. You can do this by talking to them or giving them gifts they appreciate. Each interaction affects your relationship status. When you have a good relationship with an NPC, they will be more likely to help you during quests that require assistance. 

AI is used to generate realistic and dynamic responses from NPCs—whether you're having a casual conversation, offering them a gift, or asking for help on a quest.

## Features

- **AI-Powered Dialogue**: NPCs respond dynamically using AI language models
- **Relationship System**: Build relationships with villagers through interactions and gifts
- **Quest System**: Complete procedurally generated quests requiring item collection and NPC help
- **Tile-Based World**: Explore a village environment with interactive elements
- **Multiple NPCs**: Interact with unique characters including:
  - Tomo the blacksmith (grumpy but skilled)
  - Lira the flower shop owner (cheerful nature lover)
  - Anna the innkeeper (friendly but clumsy)

## Project Structure

- `backend/`: FastAPI server for AI dialogue integration
- `characters/`: NPC implementation and behavior
- `dialogue_box/`: UI system for conversations
- `items/`: Item system and inventory management
- `levels/`: Map and environment implementation
- `main/`: Game controller and main scene
- `player/`: Player behavior and statistics tracking
- `quests/`: Quest generation and management
- `utils/`: Utility functions including AI integration

## Technologies

- **Frontend**: Godot Engine 4.x (GDScript)
- **Backend**: Python FastAPI
- **AI Models**: Support for multiple language models:
  - OpenAI ChatGPT
  - DeepSeek AI
  - Ollama (local models)

## Setup

### Prerequisites

- Godot Engine 4.x
- Python 3.8+
- API keys for AI services (optional)

### Backend Setup

1. Navigate to the backend directory:
   ```
   cd backend
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Configure environment variables (create a `.env` file):
   ```
   OPENAI_API_KEY=your_key_here  # Optional
   DEEPSEEK_API_KEY=your_key_here  # Optional
   OLLAMA_BASE_URL=http://localhost:11434  # For local models
   ```

4. Start the backend server:
   ```
   python main.py
   ```

### Frontend Setup

1. Open the project in Godot Engine
2. Run the project from the editor or export for your platform

## Development

The game is structured with a modular design allowing for easy expansion:

- Add new NPCs by creating instances of the NPC scene
- Create new quests by modifying the quest generation in `quests.gd`

## Credits

- Character sprites and tile assets from [Asset source]
- Audio from [Audio source]