from elasticsearch import Elasticsearch
from app.core.config import settings
import logging

es_client = Elasticsearch(
    settings.ELASTICSEARCH_URL,
    verify_certs=False
)

def init_elasticsearch():
    # Create the spots index if it doesn't exist
    index_name = "spots"
    try:
        if not es_client.indices.exists(index=index_name):
            es_client.indices.create(
                index=index_name,
                body={
                    "mappings": {
                        "properties": {
                            "name": {"type": "text"},
                            "description": {"type": "text"},
                            "category": {"type": "keyword"},
                            "tags": {"type": "text"},
                            "location": {"type": "geo_point"}
                        }
                    }
                }
            )
            logging.info(f"Created Elasticsearch index: {index_name}")
    except Exception as e:
        logging.error(f"Failed to initialize Elasticsearch index: {e}")

def get_es():
    return es_client
