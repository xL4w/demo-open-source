"""Assesses the security grade of internal web service
certificates based on their cipher suites and checks for weak ciphers.
"""
import ssl
import sys
import http.client
import logging
from datetime import datetime, timedelta
from urllib.parse import urlparse
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.backends import default_backend

from weak_ciphers import WEAK_CIPHERS  # Import from weak_ciphers.py
from user_agents import USER_AGENTS  # Import from user_agents.py
from grade_certificate import grade_certificate
from weak_ciphers_enabled import check_weak_ciphers_enabled


logging.basicConfig(level=logging.INFO)
              

# Main execution logic (same as before)
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python ssl_check.py <url_or_hostname> [port]")
        print("Example: python ssl_check.py https://www.example.com 443")
        sys.exit(1)

    url_or_hostname = sys.argv[1]
    port = 443  # Default port
    if len(sys.argv) > 2:
        try:
            PORT = int(sys.argv[2])  # Renamed port to PORT for the constant
        except ValueError:
            print("Invalid port number. Using default port 443.")
    else:
        PORT = port

    # Validating the input for either a URL or a hostname
    parsed_url = urlparse(url_or_hostname)
    if not parsed_url.scheme:  # If there's no scheme, it's likely a hostname
        hostname = url_or_hostname
    elif parsed_url.scheme in ("http", "https"):
        hostname = parsed_url.hostname
    else:
        raise ValueError("Invalid URL scheme. Only 'http' and 'https' are supported.")

    if not hostname:
        raise ValueError("Hostname could not be extracted from the URL.")

    result = grade_certificate(hostname, PORT)
    # Check if there's an error in the result
    if 'error' in result:
        print(result['error'])
    else:
        # List of protocols to test
        protocols = ["http", "https", "ssl"]
        # Check if weak cipher suites are enabled
        check_weak_ciphers_enabled(url_or_hostname, protocols)
