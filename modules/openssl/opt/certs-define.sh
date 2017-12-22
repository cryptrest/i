#!/bin/sh

CRYPTREST_OPENSSL_SERVER_CIPHERS=''

CRYPTREST_OPENSSL_DHPARAM_KEY_FILE="$CRYPTREST_OPENSSL_SSL_DOMAIN_DIR/dhparam.pem"
CRYPTREST_OPENSSL_ECDSA_KEY_FILE="$CRYPTREST_OPENSSL_SSL_DOMAIN_DIR/ecdsa.key"
CRYPTREST_OPENSSL_ECDSA_CSR_FILE="$CRYPTREST_OPENSSL_SSL_DOMAIN_DIR/ecdsa.csr"
CRYPTREST_OPENSSL_CSR_CONF_FILE="$CRYPTREST_OPENSSL_ETC_DIR/csr-$CRYPTREST_DOMAIN.conf"
CRYPTREST_OPENSSL_SESSION_TICKET_FILE="$CRYPTREST_OPENSSL_SSL_DOMAIN_DIR/session_ticket.key"


openssl_domain_dir_define()
{
    mkdir -p "$CRYPTREST_OPENSSL_SSL_DOMAIN_DIR" && \
    chmod 700 "$CRYPTREST_OPENSSL_SSL_DOMAIN_DIR"
}


openssl_session_ticket_key_define()
{
    openssl rand 80 > "$CRYPTREST_OPENSSL_SESSION_TICKET_FILE"
}

# Ciphers
openssl_ciphers_define()
{
    for k in $(openssl ciphers | tr ':' ' '); do
        echo "$k" | grep '128' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'PSK' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'CBC' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'SRP' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep '^DHE' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'SHA$' > /dev/null
        [ $? -eq 0 ] && continue

        CRYPTREST_OPENSSL_SERVER_CIPHERS="$CRYPTREST_OPENSSL_SERVER_CIPHERS:$k"
    done
}

# HD Param
openssl_hd_param_define()
{
    openssl dhparam -out "$CRYPTREST_OPENSSL_DHPARAM_KEY_FILE" "$CRYPTREST_SSL_KEY_SIZE"
}

# ECDSA
openssl_ecdsa_define()
{
    openssl ecparam -genkey -name secp384r1 | openssl ec -out "$CRYPTREST_OPENSSL_ECDSA_KEY_FILE"
}

# Certificate Signing Request (CSR)
openssl_csr_define()
{
    openssl req -new -sha512 -key "$CRYPTREST_OPENSSL_ECDSA_KEY_FILE" -nodes -out "$CRYPTREST_OPENSSL_ECDSA_CSR_FILE" -outform pem
}

# ECDSA
openssl_ecdsa_define__()
{
    if [ -f "$CRYPTREST_OPENSSL_CSR_CONF_FILE" ]; then
        openssl req -new -sha512 -key "$CRYPTREST_OPENSSL_PRIVATE_KEY_FILE" -out "$CRYPTREST_OPENSSL_ECDSA_CSR_FILE" -subj "/CN=$CRYPTREST_DOMAIN" -config "$CRYPTREST_OPENSSL_CSR_CONF_FILE"
#        openssl ecparam -genkey -name secp384r1 | openssl ec -out "$CRYPTREST_OPENSSL_ECDSA_KEY_FILE"
#        openssl req -new -sha256 -key "$CRYPTREST_OPENSSL_ECDSA_CSR_FILE" -nodes -out "$CRYPTREST_OPENSSL_ECDSA_CSR_FILE" -outform pem
    fi
}

# PUBLIC_KEY_PINS
openssl_public_key_pins_define()
{
    local hash=''

#    for bit in $CRYPTREST_SSL_BITS; do
#        # ECDSA
#        hash="$(openssl ec -pubout -in "$CRYPTREST_LETSENCRYPT_ECDSA_CSR_FILE" -outform DER | openssl dgst -sha${bit} -binary | openssl enc -base64)"
#        CRYPTREST_PUBLIC_KEY_PINS="${CRYPTREST_PUBLIC_KEY_PINS}pin-sha${bit}=\"${hash}\"; "
#    done
}
