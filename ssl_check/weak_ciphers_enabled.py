"""Functions to check if weak ciphers are enabled."""

import http.client
import logging
import ssl
from datetime import datetime
from urllib.parse import urlparse
from grade_certificate import grade_certificate
from weak_ciphers import WEAK_CIPHERS
from user_agents import USER_AGENTS


def check_weak_ciphers_enabled(url, protocols):
    """Check if weak cipher suites are enabled for the specified URL."""

    for protocol in protocols:
        for cipher in WEAK_CIPHERS:
            for user_agent in USER_AGENTS:
                try:
                    parsed_url = urlparse(url)
                    hostname = parsed_url.hostname

                    if protocol == "http":
                        logging.info(f"Skipping weak cipher check for HTTP URL: {url}")
                        continue  # Skip to the next iteration (cipher or user_agent)
                    
                    # Use `with` statements for automatic cleanup
                    else:
                        ssl_context = (
                            ssl.create_default_context()
                            if protocol == "https"
                            else None
                        )
                        if protocol == "ssl":
                            ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
                            ssl_context.set_ciphers(cipher)
                            ssl_context.options |= ssl.OP_NO_RENEGOTIATION

                        with http.client.HTTPSConnection(
                            hostname, timeout=10, context=ssl_context
                        ) as connection:
                            headers = {"User-Agent": user_agent}
                            connection.request("GET", parsed_url.path, headers=headers)
                            response = connection.getresponse()

                            # Get cipher from the socket
                            cipher_info = connection.sock.cipher()
                            if cipher_info:
                                cipher_name = cipher_info[0]
                                # Grade certificate
                                result = grade_certificate(hostname, cipher_name)
                            else:
                                result = {"error": "No cipher info found."}

                    # Check if the response status code indicates success and report weak cipher
                    if response.status in [200, 302] and not result.get("error"):
                        logging.debug(
                            "Weak cipher suite %s is enabled for %s with user-agent %s using protocol %s",
                            cipher,
                            url,
                            user_agent[:30],
                            protocol,
                        )
                        print(
                            f"Weak cipher suite {cipher} is enabled for {url} with user-agent {user_agent[:30]}... using protocol {protocol} at {datetime.now()}"
                        )

                except http.client.HTTPException as e:
                    logging.debug("An HTTP error occurred:", e)
                    logging.debug(
                        "The server does not support the specified cipher suites."
                    )
                except Exception as e:  # Catch-all exception at the end
                    logging.debug("An error occurred:", e)
