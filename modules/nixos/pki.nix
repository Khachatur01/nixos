# Trust the ATG internal root CA (fingerprint checked against atg-cert.sh ROOT_FP).
{
  security.pki.certificateFiles = [ ./certs/atg-root-ca.crt ];
}
