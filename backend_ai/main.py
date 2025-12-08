# main.py
import os
import json
from typing import List, Dict, Any
from dotenv import load_dotenv
from fastapi import FastAPI, Request
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore
import google.generativeai as genai
from collections import Counter
from datetime import datetime, timedelta

# load env
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
FIREBASE_KEY_PATH = os.getenv("FIREBASE_KEY_PATH", "firebase_key.json")
PORT = int(os.getenv("PORT", 8000))

cred = credentials.Certificate(FIREBASE_KEY_PATH)

if not firebase_admin._apps:  # check if any app is already initialized
    firebase_admin.initialize_app(cred)

db = firestore.client()


# Configure Gemini
genai.configure(api_key=GEMINI_API_KEY)
# choose model; adjust if you have access to different Gemini family models
GENIE_MODEL = "models/gemini-1.5"  # adjust name if different in your account

app = FastAPI(title="SmartShopBot Backend")

class ChatRequest(BaseModel):
    message: str
    user_id: str = None  # optional

# ---------- Helper functions ----------
def fetch_product_by_name_or_id(query: str, limit: int = 10) -> List[Dict[str, Any]]:
    """
    Returns a list of product dicts that match query (naive approach: name contains or id equals)
    """
    q_lower = query.lower()
    results = []

    # 1) try exact id
    try:
        doc_ref = db.collection("products").document(query)
        doc = doc_ref.get()
        if doc.exists:
            results.append(doc.to_dict())
            return results
    except Exception:
        pass

    # 2) search by name (limited)
    products = db.collection("products").limit(limit).stream()
    for p in products:
        d = p.to_dict()
        name = (d.get("name") or "").lower()
        if q_lower in name or any(q_lower in tag.lower() for tag in d.get("tags", [])):
            results.append(d)
    return results

def fetch_top_sold_products(limit: int = 5) -> List[Dict[str, Any]]:
    """
    Return top sold products using 'sold_count' if available.
    If sold_count not present, compute from orders collection (less efficient).
    """
    # Try fast path: products with sold_count field
    query = db.collection("products").where("sold_count", ">", 0).order_by("sold_count", direction=firestore.Query.DESCENDING).limit(limit).stream()
    prod_list = [p.to_dict() for p in query]
    if prod_list:
        return prod_list

    # Fallback: compute counts from recent orders (e.g., last 90 days)
    cutoff = datetime.utcnow() - timedelta(days=90)
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
    """
    Create a compact summary string of product information for the prompt.
    Include only essential fields to avoid token explosion.
    """
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


def call_gemini_system_and_user(system_prompt: str, user_prompt: str) -> str:
    """
    Calls Gemini via the google.generativeai SDK using chat.create
    """
    try:
        response = genai.chat.create(
            model=GENIE_MODEL,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            max_output_tokens=512
        )

        # Extract text depending on SDK
        if hasattr(response, "last"):
            # SDK >= 1.1.x usually has .last
            text = response.last
        elif hasattr(response, "candidates") and response.candidates:
            # older SDKs may have candidates list
            text = response.candidates[0].content
        else:
            text = str(response)

        return text.strip()
    except Exception as e:
        return f"Error calling Gemini API: {e}"



# ---------- Prompt templates ----------
SYSTEM_PROMPT = (
    "You are SmartShopBot, a helpful assistant for an e-commerce store called SmartShop.\n"
    "You MUST answer questions only using the provided product data (do not hallucinate extra products).\n"
    "If a user asks for trending/most sold/most interesting products, use the provided sales/views metrics.\n"
    "Be concise, give availability in human terms, and include product id when helpful."
)

# ---------- API endpoint ----------
@app.post("/chat")
async def chat_endpoint(req: ChatRequest):
    user_msg = req.message.strip()
    # decide intent heuristically (could use a light intent classifier)
    # If contains words like "available", "size", "in stock" -> check products
    user_lower = user_msg.lower()

    # 1) If user asks about availability or size -> search products by name
    if any(k in user_lower for k in ["available", "in stock", "size", "have", "stock", "is there"]):
        # Extract product name heuristically: keep simple — we will take entire message as search key
        search_key = user_msg
        found = fetch_product_by_name_or_id(search_key, limit=10)
        summary = summarize_products_for_prompt(found, max_items=8)
        user_prompt = (
            f"User question: {user_msg}\n\nProduct data:\n{summary}\n\n"
            "Answer based ONLY on product data. If product not found, say so and suggest nearest matches."
        )
        reply = call_gemini_system_and_user(SYSTEM_PROMPT, user_prompt)
        return {"reply": reply}

    # 2) If user asks trending or most sold or most interesting
    if any(k in user_lower for k in ["trending", "most sold", "top selling", "most interesting", "popular", "best seller"]):
        top = fetch_top_sold_products(limit=6)
        summary = summarize_products_for_prompt(top, max_items=6)
        user_prompt = (
            f"User question: {user_msg}\n\nTop products data:\n{summary}\n\n"
            "Using only this data, answer who is trending and why (use sold_count/views)."
        )
        reply = call_gemini_system_and_user(SYSTEM_PROMPT, user_prompt)
        return {"reply": reply}

    # 3) Default: try search products and let Gemini answer using the small dataset
    found = fetch_product_by_name_or_id(user_msg, limit=6)
    summary = summarize_products_for_prompt(found, max_items=6)
    user_prompt = (
        f"User question: {user_msg}\n\nProduct data:\n{summary}\n\n"
        "Answer using only the provided product data where possible. If unclear, ask a clarifying question."
    )
    reply = call_gemini_system_and_user(SYSTEM_PROMPT, user_prompt)
    return {"reply": reply}

# Run if executed directly (development)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=PORT, reload=True)
