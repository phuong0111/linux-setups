#!/usr/bin/env bash
set -euo pipefail

# Default values
EXPOSE_PORT=80
INNER_PORT=3000

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --expose-port)
      EXPOSE_PORT="$2"
      shift 2
      ;;
    --inner-port)
      INNER_PORT="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: ./setup-nginx.sh --expose-port 80 --inner-port 3000"
      exit 1
      ;;
  esac
done

echo "🚀 Setting up Nginx: External ($EXPOSE_PORT) -> Internal ($INNER_PORT)"

# 1. Handle Apache Conflict (Important!)
if systemctl is-active --quiet apache2 && [ "$EXPOSE_PORT" == "80" ]; then
    echo "⚠️  Apache is running on port 80. Disabling Apache to allow Nginx to start..."
    sudo systemctl stop apache2
    sudo systemctl disable apache2
fi

# 2. Install Nginx
if ! command -v nginx &>/dev/null; then
    echo "📦 Installing Nginx..."
    sudo apt update && sudo apt install -y nginx
fi

# 3. Create Configuration
CONF_NAME="proxy_${EXPOSE_PORT}_to_${INNER_PORT}"
CONF_FILE="/etc/nginx/sites-available/$CONF_NAME"

echo "🔧 Writing configuration to $CONF_FILE..."
sudo tee "$CONF_FILE" > /dev/null <<EOF
server {
    listen $EXPOSE_PORT;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:$INNER_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# 4. Enable and Restart
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf "$CONF_FILE" /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

echo "✅ Success! Port $EXPOSE_PORT is now proxying to $INNER_PORT."
