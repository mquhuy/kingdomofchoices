from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import openai
import os
import requests
import re
import json

app = FastAPI()

openai.api_key = os.getenv("OPENAI_API_KEY", "sk-...")
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "ds-...")  # Set your DeepSeek key

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
OLLAMA_DEFAULT_MODEL = os.getenv("OLLAMA_MODEL", "phi4-mini")
OPENAI_DEFAULT_MODEL = os.getenv("OPENAI_MODEL", "gpt-3.5-turbo")

CHARACTERS = {
    "Tomo": "the blacksmith, male, 35 years old, loves to forge weapons and armor. Not very talkative. Quite rude and grumpy.",
    "Lira": "the flower shop owner, 20 years old, loves flowers and nature. Very friendly and talkative.",
    "Anna": "the innkeeper, 60 years old, loves to cook and serve food. Very friendly and talkative, but a bit clumsy."
}

base_prompt = """You are an NPC in a cozy village game. Respond in a friendly, in-character way.
Keep the answer short and concise. Under 200 characters.
Avoid being too formal. 
Decide your response based on the character you are playing, the difficulty of the request or question,
the context of the game, and the personal relationship between the character and the user.
Generate the response as the exact character that is given in the context."""

help_prompt = base_prompt + """
Respond using a json format with a "text" key, and a "agree" key with a boolean value, indicating that you agree to help.
For example:
{
    "agree": "true",
    "text": "Of course! I can help you with that. What do you need?"
}

or

{
    "agree": "false",
    "text": "No. I'm busy. Go away."
}
"""

gift_prompt = base_prompt + """
Respond using a json format with a "text" key, and a "rate" key with a integer value, your interest in the gift.
The value should be between -2 and 2, with -2 being "I hate it" and 2 being "I love it".
For example:
{
    "rate": 0,
    "text": "OK Thanks. I guess I can use it."
}

or

{
    "rate": 2,
    "text": "Thank you! I love it! It's so beautiful!"
}

or

{
    "rate": -2,
    "text": "I hate it! Why would you give me this?"
}
"""

chat_prompt = base_prompt + """
Respond using a json format with a "text" key, and a "rate" key with a integer value, your interest in the chat topic.
The value should be between -2 and 2, with -2 being "I hate it" and 2 being "I love it".
For example:
{
    "rate": 0,
    "text": "OK Thanks. Nice chat."
}
or
{
    "rate": 2,
    "text": "Thank you! I love it! It's so nice of you!"  
}
or
{
    "rate": -2,
    "text": "I hate it! Why would you talk to me like that?"
}
"""

human_prompt = """
You are a human player in a cozy village game. Respond in a friendly, in-character way.
Keep the answer short and concise. Under 200 characters.
Use a friendly tone and avoid being too formal."""

class AIRequest(BaseModel):
    npc_name: str
    interaction_type: str
    relationship_score: int
    ask_count: int = 0
    quest_type: str = None
    model: str = None  # "gpt-4", "deepseek-chat", "phi4-mini", etc.

@app.post("/api/ai_dialogue")
async def ai_dialogue(req: AIRequest):
    print(req)
    if req.npc_name not in CHARACTERS:
        print("Invalid NPC name")
        return JSONResponse(content={"text": "Invalid NPC name. Please provide a valid NPC name."}, status_code=400)
    npc_description = CHARACTERS[req.npc_name]
    prompt = f"""You are {req.npc_name}. {npc_description}
Your personal relationship with the player is {req.relationship_score}, with the default value is 3 and the maximum value is 20."""
    if req.interaction_type == "ask for help":
        if req.quest_type is None:
            print("Missing quest type")
            return JSONResponse(content={"text": "Invalid request format. Please provide all required fields."}, status_code=400)
        prompt += f"""
The lower the value, the more rude you are, and less likely you are to help.
The higher the value, the more friendly you are, and more likely you are to help.
You have helped the player with this quest {req.ask_count} times.
The higher the number, the less likely you are to help.
The player asked you to help with a quest: {req.quest_type}."""
        system_prompt = help_prompt     
    elif req.interaction_type == "gift":
        if req.quest_type is None:
            print("Missing quest type")
            return JSONResponse(content={"text": "Invalid request format. Please provide all required fields."}, status_code=400)
        prompt += f"""
The player gave you a gift. It's a {req.quest_type}.

The lower the value, the more rude you are, and less likely you are to help.
The higher the value, the more friendly you are, and more likely you are to help.
You have helped the player with this quest {req.ask_count} times.
The higher the number, the less likely you are to help.
The player asked you to help with a quest: {req.quest_type}."""
        system_prompt = gift_prompt
    elif req.interaction_type == "think of chat":
        system_prompt = human_prompt
        prompt = f"""You want to get closer to NPC {req.npc_name}, {npc_description}.
Your personal relationship with the NPC is {req.relationship_score}, with the default value is 3 and the maximum value is 20.
The lower the value, the less likely the NPC will be friendly to you.
You need to think of 3 chat topics to get closer to the NPC.
Come up with 3 chat topics that are related to the NPC, and are likely to be interesting to the NPC.
Each topic should be short and concise, under 200 characters.
The topics should be related to the NPC's interests, hobbies, and personality.
Answer in a json format with 3 "option" key with a list of 3 topics.
For example:
{{
    "option 1": "What do you think about the weather?",
    "option 2": "What do you think about the village?",
    "option 3": "What do you think about the blacksmith?"
}}
"""
    elif req.interaction_type == "chat":
        system_prompt = chat_prompt
        prompt = f"""You are {req.npc_name}. {npc_description}
Your personal relationship with the player is {req.relationship_score}, with the default value is 3 and the maximum value is 20.
The lower the value, the more rude you are, and less likely you like them.
The higher the value, the more friendly you are, and more likely you like them.
The player wanted a small talk with you.
The player said: {req.quest_type}."""
    else:
        return JSONResponse(content={"text": "Invalid request format. Please provide all required fields."}, status_code=400)

    try:
        model = req.model or OPENAI_DEFAULT_MODEL

        if model.lower().startswith("gpt-"):
            # OpenAI
            response = openai.ChatCompletion.create(
                model=model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=100,
                temperature=0.9,
            )
            ai_text = response.choices[0].message["content"].strip()

        elif model.lower().startswith("deepseek"):
            # DeepSeek API (adjust endpoint/model as needed)
            # Example endpoint for DeepSeek Chat API:
            deepseek_url = "https://api.deepseek.com/v1/chat/completions"
            headers = {
                "Authorization": f"Bearer {DEEPSEEK_API_KEY}",
                "Content-Type": "application/json",
            }
            data = {
                "model": model,  # e.g., "deepseek-chat"
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": prompt},
                ],
                "max_tokens": 100,
                "temperature": 0.9,
            }
            print(data)
            resp = requests.post(deepseek_url, json=data, headers=headers, timeout=60)
            resp.raise_for_status()
            result = resp.json()
            ai_text = result["choices"][0]["message"]["content"].strip()

        else:
            # Ollama
            ollama_url = f"{OLLAMA_BASE_URL}/api/generate"
            ollama_model = model or OLLAMA_DEFAULT_MODEL
            prompt = system_prompt + prompt
            ollama_data = {
                "model": ollama_model,
                "prompt": prompt,
                "stream": False
            }
            resp = requests.post(ollama_url, json=ollama_data, timeout=60)
            resp.raise_for_status()
            data = resp.json()
            ai_text = data.get("response", "").strip()
            if not ai_text:
                raise Exception(f"Ollama returned empty response: {data}")
        ai_text_inner = ai_text
        print(ai_text_inner)
        codeblock_match = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", ai_text, re.IGNORECASE)
        if codeblock_match:
            ai_text_inner = codeblock_match.group(1).strip()
        try:
            parsed = json.loads(ai_text_inner)
            print(parsed)
            return JSONResponse(content=parsed)
        except Exception:
            pass  # fallback to default response
        return JSONResponse(content={"text": ai_text})
    except Exception as e:
        return JSONResponse(content={"text": f"AI error: {str(e)}"}, status_code=500)