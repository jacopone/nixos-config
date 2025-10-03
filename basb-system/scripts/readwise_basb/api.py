"""Readwise Reader API client."""

import subprocess
import json
import time
from typing import Dict, List, Optional, Any

from .config import config


class ReadwiseAPI:
    """Client for Readwise Reader API v3."""

    def __init__(self):
        self.config = config
        self.config.load()
        self.base_url = self.config.api_base_url
        self.token = self.config.api_token
        self.headers = {
            "Authorization": f"Token {self.token}",
            "Content-Type": "application/json",
        }
        self.rate_limit_delay = 60 / 20  # 20 requests per minute

    def _request(self, method: str, endpoint: str, **kwargs) -> Dict[str, Any]:
        """Make an API request with rate limiting using httpie."""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"

        # Rate limiting
        time.sleep(self.rate_limit_delay)

        # Build httpie command
        cmd = ["http", "--check-status", "--json"]

        if method == "GET":
            cmd.append("GET")
        elif method == "POST":
            cmd.append("POST")
        elif method == "PATCH":
            cmd.append("PATCH")
        elif method == "DELETE":
            cmd.append("DELETE")

        cmd.append(url)
        cmd.append(f"Authorization:Token {self.token}")

        # Add JSON body if present
        if "json" in kwargs:
            for key, value in kwargs["json"].items():
                cmd.append(f"{key}:={json.dumps(value)}")

        # Add query params if present
        if "params" in kwargs:
            for key, value in kwargs["params"].items():
                cmd.append(f"{key}=={value}")

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)

            # Handle rate limiting
            if "429" in result.stderr:
                time.sleep(60)
                return self._request(method, endpoint, **kwargs)

            if result.stdout:
                return json.loads(result.stdout)
            return {"status": "success"}

        except subprocess.CalledProcessError as e:
            if "429" in e.stderr:
                time.sleep(60)
                return self._request(method, endpoint, **kwargs)
            raise Exception(f"API request failed: {e.stderr}")

    def test_auth(self) -> bool:
        """Test API authentication."""
        try:
            self._request("GET", "/api/v2/auth/")
            return True
        except Exception as e:
            print(f"Authentication failed: {e}")
            return False

    def list_documents(
        self,
        updated_after: Optional[str] = None,
        location: Optional[str] = None,
        category: Optional[str] = None,
        tag: Optional[str] = None,
        page_cursor: Optional[str] = None,
    ) -> Dict[str, Any]:
        """List documents with optional filters."""
        params = {}
        if updated_after:
            params["updatedAfter"] = updated_after
        if location:
            params["location"] = location
        if category:
            params["category"] = category
        if tag:
            params["tag"] = tag
        if page_cursor:
            params["pageCursor"] = page_cursor

        return self._request("GET", "/list/", params=params)

    def get_document(self, document_id: str) -> Dict[str, Any]:
        """Get a single document by ID."""
        # Note: The API doesn't have a single document endpoint
        # We'll use list with filter instead
        documents = self.list_documents()
        for doc in documents.get("results", []):
            if doc["id"] == document_id:
                return doc
        raise ValueError(f"Document {document_id} not found")

    def update_document(
        self,
        document_id: str,
        title: Optional[str] = None,
        author: Optional[str] = None,
        location: Optional[str] = None,
        tags: Optional[List[str]] = None,
        notes: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update a document."""
        data = {}
        if title:
            data["title"] = title
        if author:
            data["author"] = author
        if location:
            data["location"] = location
        if tags is not None:
            data["tags"] = tags
        if notes:
            data["notes"] = notes

        return self._request("PATCH", f"/update/{document_id}/", json=data)

    def delete_document(self, document_id: str) -> bool:
        """Delete a document."""
        try:
            self._request("DELETE", f"/delete/{document_id}/")
            return True
        except Exception:
            return False

    def list_tags(self) -> List[str]:
        """List all tags."""
        response = self._request("GET", "/tags/")
        return response.get("tags", [])

    def save_document(
        self,
        url: str,
        html: Optional[str] = None,
        title: Optional[str] = None,
        author: Optional[str] = None,
        tags: Optional[List[str]] = None,
        location: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Save a new document."""
        data = {"url": url}
        if html:
            data["html"] = html
        if title:
            data["title"] = title
        if author:
            data["author"] = author
        if tags:
            data["tags"] = tags
        if location:
            data["location"] = location

        return self._request("POST", "/save/", json=data)

    def list_all_documents(self) -> List[Dict[str, Any]]:
        """List all documents with pagination."""
        all_documents = []
        page_cursor = None

        while True:
            response = self.list_documents(page_cursor=page_cursor)
            results = response.get("results", [])
            all_documents.extend(results)

            page_cursor = response.get("nextPageCursor")
            if not page_cursor:
                break

        return all_documents


# Global API client instance
api = ReadwiseAPI()
