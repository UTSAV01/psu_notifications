import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import datetime
import uuid
import os
import pandas as pd
import logging
import hashlib
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# 1. Initialize Firebase Admin SDK
# Configure via .env file to avoid hardcoding strings
try:
    cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "serviceAccountKey.json")
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    logger.info("Successfully connected to Firebase Firestore!")
except Exception as e:
    logger.error(f"Error connecting to Firebase! Did you place {cred_path}? Exception: {e}")
    exit(1)

# 2. Setup the Scrape Logic
def fetch_latest_psu_jobs():
    logger.info("Fetching jobs from PSU websites...")
    jobs = []
    excel_path = os.getenv("EXCEL_PATH", "PSU Recruitment Data and Link Generation.xlsx")

    if not os.path.exists(excel_path):
        logger.error(f"Error: {excel_path} not found. Please ensure it is in the backend directory.")
        return jobs

    try:
        df = pd.read_excel(excel_path)
        # Normalize column names in case of whitespace/case issues
        df.columns = df.columns.str.strip().str.lower()

        # The user's columns might not exactly be lowercased, so we check for 'name of psu' and 'notification link'
        name_col = 'name of psu'
        link_col = 'notification link'

        # Safety check if column names change slightly
        for col in df.columns:
            if "name" in col and "psu" in col:
                name_col = col
            if "link" in col:
                link_col = col
        
        for index, row in df.iterrows():
            psu_name = row.get(name_col)
            link = row.get(link_col)

            # Skip rows where name or link is empty
            if pd.isna(psu_name) or pd.isna(link):
                continue
            
            # Attempt preliminary scraping logic 
            role_title = "General Recruitment Check"
            try:
                # Basic web scraping generic fallback
                headers = {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
                }
                response = requests.get(link, headers=headers, timeout=10)
                response.raise_for_status()
                soup = BeautifulSoup(response.content, 'html.parser')
                
                if soup.title and soup.title.string:
                    extracted_title = soup.title.string.strip()
                    # Keep title length manageable
                    role_title = extracted_title[:97] + "..." if len(extracted_title) > 100 else extracted_title
            except Exception as e:
                logger.warning(f"Failed to scrape {link} for {psu_name}. Defaulting to generic role. Error: {e}")

            # Generate deterministic ID using SHA-256 hash of PSU Name, Link, and Role
            unique_string = f"{str(psu_name).strip()}_{str(link).strip()}_{str(role_title).strip()}"
            job_id = hashlib.sha256(unique_string.encode('utf-8')).hexdigest()

            jobs.append({
                "id": job_id,
                "psuName": str(psu_name).strip(),
                "role": role_title, 
                "notificationLink": str(link).strip(),
                "location": "All India",
                "datePosted": datetime.datetime.now().strftime("%b %d, %Y"),
                "deadline": (datetime.datetime.now() + datetime.timedelta(days=15)).strftime("%b %d, %Y"),
                "isStatePsu": False
            })
            
    except Exception as e:
        logger.error(f"Error parsing Excel file: {e}")

    return jobs

# 3. Push to Firestore
def push_jobs_to_firestore(jobs):
    notifications_ref = db.collection('notifications')
    
    for job in jobs:
        doc_ref = notifications_ref.document(job['id'])
        doc = doc_ref.get()
        
        if doc.exists:
            # Upsert (Merge with existing document)
            doc_ref.set(job, merge=True)
            logger.info(f"Updated existing job: {job['psuName']} - {job['role']}")
        else:
            # Job doesn't exist, let's insert it
            doc_ref.set(job)
            logger.info(f"Added new job: {job['psuName']} - {job['role']}")

if __name__ == "__main__":
    latest_jobs = fetch_latest_psu_jobs()
    push_jobs_to_firestore(latest_jobs)
    logger.info("Scraper run completed successfully.")
