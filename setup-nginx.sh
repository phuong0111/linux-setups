#!/usr/bin/env bash
set -euo pipefail

# Default values
EXPOSE_PORT=443
INNER_PORT=3000

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --expose-port) EXPOSE_PORT="$2"; shift 2 ;;
    --inner-port)  INNER_PORT="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo "🚀 Setting up Self-Signed HTTPS: Port $EXPOSE_PORT -> Internal $INNER_PORT"

# 1. Install Nginx
if ! command -v nginx &>/dev/null; then
    sudo apt update && sudo apt install -y nginx
fi

# 2. Create Directory for SSL Keys
SSL_DIR="/etc/nginx/ssl"
sudo mkdir -p "$SSL_DIR"

# 3. Generate Self-Signed Certificate
# -nodes: No password on the key (so Nginx can start automatically)
# -subj: Skips the interactive questions
echo "🔐 Generating self-signed certificate..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/nginx-selfsigned.key" \
    -out "$SSL_DIR/nginx-selfsigned.crt" \
    -subj "/C=US/ST=Dev/L=Dev/O=Dis/CN=localhost"

# 4. Create Nginx Configuration
CONF_FILE="/etc/nginx/sites-available/self-signed-proxy"
echo "🔧 Writing configuration to $CONF_FILE..."

sudo tee "$CONF_FILE" > /dev/null <<EOF
server {
    listen $EXPOSE_PORT ssl;
    server_name _;

    ssl_certificate $SSL_DIR/nginx-selfsigned.crt;
    ssl_certificate_key $SSL_DIR/nginx-selfsigned.key;

    # Basic SSL optimizations
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:$INNER_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# Optional: Redirect HTTP to HTTPS
server {
    listen 80;
    server_name _;
    return 301 https://\$host\$request_uri;
}
EOF

# 5. Enable and Restart
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf "$CONF_FILE" /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

echo -e "\n✅ Success! Access your app at https://YOUR_IP_OR_LOCALHOST:$EXPOSE_PORT"
echo "⚠️  Note: Your browser will show a security warning because this certificate is self-signed."
