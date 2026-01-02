# main.py
import os
import json
from typing import List, Dict, Any
from dotenv import load_dotenv
from fastapi import FastAPI
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore
# import google.generativeai as genai
from collections import Counter
from datetime import datetime, timedelta
from google import genai
from datetime import datetime, timezone, timedelta

# ---------- Load env ----------
load_dotenv()
GEMINI_API_KEY = os.getenv("BACKUP_GEMINI_API_KEY")
FIREBASE_KEY_PATH = os.getenv("FIREBASE_KEY_PATH", "firebase_key.json")
PORT = int(os.getenv("PORT", 8000))

# ---------- Initialize Firebase ----------
if not firebase_admin._apps:
    cred = credentials.Certificate(FIREBASE_KEY_PATH)
    firebase_admin.initialize_app(cred)
db = firestore.client()

# ---------- Configure Gemini ----------
GEMINI_MODEL = "gemini-2.5-flash"  # Make sure this model exists in your account
# genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
client = genai.Client()
# Create a client with your API key
client = genai.Client(api_key=os.getenv("BACKUP_GEMINI_API_KEY"))

# Generate content (chat)
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Hello! This is a test message from SmartShopBot."
)

print(response.text)

# ---------- FastAPI ----------
app = FastAPI(title="SmartShopBot Backend")

# ---------- Pydantic model ----------
class ChatRequest(BaseModel):
    message: str
    user_id: str = None  # optional

# ---------- Helper functions ----------
def fetch_product_by_name_or_id(query: str, limit: int = 10) -> List[Dict[str, Any]]:
    results = []
    q_lower = query.lower()

    # 1) exact id
    try:
        doc_ref = db.collection("products").document(query)
        doc = doc_ref.get()
        if doc.exists:
            results.append(doc.to_dict())
            return results
    except Exception:
        pass

    # 2) search by name or tags
    products = db.collection("products").limit(limit).stream()
    for p in products:
        d = p.to_dict()
        name = (d.get("name") or "").lower()
        if q_lower in name or any(q_lower in tag.lower() for tag in d.get("tags", [])):
            results.append(d)
    return results

#fetch all products
def fetch_all_products(limit=20):
    return [d.to_dict() for d in db.collection("products").limit(limit).stream()]


#top sold products
def fetch_top_sold_products(limit: int = 6) -> List[Dict[str, Any]]:
    try:
        # Fast path: sold_count field
        query = db.collection("products") \
                  .where("sold_count", ">", 0) \
                  .order_by("sold_count", direction=firestore.Query.DESCENDING) \
                  .limit(limit).stream()
        prod_list = [p.to_dict() for p in query]
        if prod_list:
            return prod_list
    except Exception:
        pass

    # Fallback: compute from recent orders
    cutoff = datetime.now(timezone.utc) - timedelta(days=90)
    orders = db.collection("orders").where("created_at", ">", cutoff).stream()
    counter = Counter()
    product_map = {}
    for o in orders:
        od = o.to_dict()
        for item in od.get("items", []):
            pid = item.get("product_id")
            qty = int(item.get("qty", 1))
            counter[pid] += qty
            product_map[pid] = item.get("name", pid)
    top = counter.most_common(limit)
    results = []
    for pid, cnt in top:
        doc = db.collection("products").document(pid).get()
        if doc.exists:
            d = doc.to_dict()
            d["sold_count_in_90d"] = cnt
            results.append(d)
        else:
            results.append({"product_id": pid, "name": product_map.get(pid, pid), "sold_count_in_90d": cnt})
    return results

def summarize_products_for_prompt(products: List[Dict[str, Any]], max_items: int = 10) -> str:
    out = []
    for p in products[:max_items]:
        pid = p.get("product_id") or p.get("id") or p.get("uid") or p.get("name")
        name = p.get("name", "")
        price = p.get("price", "N/A")
        sizes = p.get("sizes") or list(p.get("stock_by_size", {}).keys())
        stock_by_size = p.get("stock_by_size", {})
        sold = p.get("sold_count", p.get("sold_count_in_90d", 0))
        views = p.get("views", 0)
        out.append(json.dumps({
            "id": str(pid),
            "name": name,
            "price": price,
            "sizes": sizes,
            "stock_by_size": stock_by_size,
            "sold_count": sold,
            "views": views
        }, ensure_ascii=False))
    return "\n".join(out) or "No products found."

def format_products(products: List[Dict[str, Any]]):
    if not products:
        return "No products found."

    formatted = []
    for p in products:
        formatted.append(f"- {p.get('name')} | Price: {p.get('price')} | Sizes: {p.get('sizes', 'N/A')}")
    return "\n".join(formatted)

# ---------- Gemini call ----------
def call_gemini_system_and_user(system_prompt: str, user_prompt: str) -> str:
    try:
        client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

        # Combine system + user prompts
        prompt = f"{system_prompt}\n\nUser: {user_prompt}"

        resp = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt
        )
        return resp.text
    except Exception as e:
        import traceback; traceback.print_exc()
        return f"Gemini API call failed: {e}"

# ---------- System prompt ----------
SYSTEM_PROMPT = (
    "You are SmartShopBot, a helpful assistant for an e-commerce store called SmartShop.\n"
    "You MUST answer questions only using the provided product data (do not hallucinate extra products).\n"
    "If a user asks for trending/most sold/most interesting products, use the provided sales/views metrics.\n"
    "Be concise, give availability in human terms, and include product id when helpful."
)

# ---------- Chat endpoint ----------
@app.post("/chat")
async def chat_endpoint(req: ChatRequest):
    user_msg = req.message.strip()
    user_lower = user_msg.lower()

    # 1. User asks general product availability
    if any(x in user_lower for x in ["what products", "what do you have", "show products", "list products", "do you have any"]):
        products = fetch_all_products()
        summary = format_products(products)
        user_prompt = (
        f"User asked to know available products.\n"
        f"Here are all products:\n{summary}\n\n"
        f"Respond in a friendly way. Mention items clearly."
        )
        reply = call_gemini_system_and_user(SYSTEM_PROMPT, user_prompt)
        # reply = chat(SYSTEM_PROMPT, f"User asked product list.\nProducts:\n{summary}")
        return {"reply": reply}


    # 1) Availability / stock / size queries
    if any(k in user_lower for k in ["available", "in stock", "size", "have", "stock", "is there"]):
        found = fetch_product_by_name_or_id(user_msg, limit=10)
        summary = summarize_products_for_prompt(found, max_items=8)
        user_prompt = f"User question: {user_msg}\n\nProduct data:\n{summary}\n\nAnswer based ONLY on product data. If product not found, say so."
        reply = call_gemini_system_and_user(SYSTEM_PROMPT, user_prompt)
        return {"reply": reply}

    # 2) Trending / most sold / popular queries
    if any(k in user_lower for k in ["trending", "most sold", "top selling", "most interesting", "popular", "best seller"]):
        top_products = fetch_top_sold_products(limit=6)
        summary = summarize_products_for_prompt(top_products, max_items=6)
        user_prompt = f"User question: {user_msg}\n\nTop products data:\n{summary}\n\nAnswer using only this data, indicate who is trending and why (sold_count/views)."
        reply = call_gemini_system_and_user(SYSTEM_PROMPT, user_prompt)
        return {"reply": reply}

    # 3) Default queries
    found = fetch_product_by_name_or_id(user_msg, limit=6)
    summary = summarize_products_for_prompt(found, max_items=6)
    user_prompt = f"User question: {user_msg}\n\nProduct data:\n{summary}\n\nAnswer using only the provided product data where possible. If unclear, ask a clarifying question."
    reply = call_gemini_system_and_user(SYSTEM_PROMPT, user_prompt)
    return {"reply": reply}

# ---------- Run ----------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=PORT, reload=True)
