"""Functions for fetching and grading SSL/TLS certificates."""

import ssl
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.backends import default_backend


def grade_certificate(hostname, port=443, cipher_suite=None):  
    """Fetches, analyzes, & grades a web service cert.
    based on its cipher suite & details."""

    try:
        if cipher_suite is None:
            context = ssl.create_default_context()
            with context.wrap_socket(ssl.socket(), server_hostname=hostname) as sock:
                sock.connect((hostname, port))
                cipher_suite = sock.cipher()[0]
                cert_der = sock.getpeercert(binary_form=True)
                cert = x509.load_der_x509_certificate(cert_der, default_backend())
        else:
            cert = None  

        # Initialize cert_details with hostname and cipher_suite only
        cert_details = {"hostname": hostname, "cipher_suite": cipher_suite}

        # Check if cipher_suite is valid and not None
        if cipher_suite:
            # Cipher Suite Grading
            if cipher_suite.startswith("TLS_AES_256_GCM") or cipher_suite.startswith(
                "TLS_CHACHA20_POLY1305"
            ):
                grade = "A"
            elif cipher_suite.startswith("TLS_AES_128_GCM"):
                grade = "B"
            else:
                grade = "C"  # Potentially vulnerable

            # Update cert_details only if a cipher suite is found
            cert_details.update({"grade": grade, "vulnerable": grade < "A"})

        # Extract Certificate Details if available
        if cert:
            subject_name = cert.subject.get_attributes_for_oid(NameOID.COMMON_NAME)
            issuer_name = cert.issuer.get_attributes_for_oid(NameOID.COMMON_NAME)

            cert_details.update(
                {
                    "subject": subject_name[0].value if subject_name else None,
                    "issuer": issuer_name[0].value if issuer_name else None,
                    "not_valid_before": cert.not_valid_before.isoformat(),
                    "not_valid_after": cert.not_valid_after.isoformat(),
                }
            )

            # Extract Certificate Hierarchy (Chain)
            cert_hierarchy = []
            while cert is not None:
                cert_hierarchy.append(cert.subject.rfc4514_string())
                cert = (
                    cert.authority_cert_issuer.get_cert_for_oid(
                        cert.authority_cert_serial_number
                    )
                    if cert.authority_cert_issuer
                    else None
                )

            cert_details["hierarchy"] = cert_hierarchy

            # Extract Certificate Fields and Values
            cert_fields = {}
            for field in cert.subject:
                # pylint: disable=protected-access
                cert_fields[field.oid._name] = field.value

            cert_details["fields"] = cert_fields

    except (ssl.SSLCertVerificationError, ssl.SSLError) as e:
        return {"hostname": hostname, "error": f"Certificate Error: {e}"}
    except ConnectionRefusedError:
        return {"hostname": hostname, "error": "Connection Refused"}
    except ValueError as ve:
        return {"error": f"Value Error: {ve}"}

    return cert_details
