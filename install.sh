#!/bin/bash
set -e

# Установка Node.js (LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get update
sudo apt-get install -y nodejs

# Установка npm-run-all (глобально, если нужно)
sudo npm install -g npm-run-all

# Установка MongoDB
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/debian $(lsb_release -cs)/mongodb-org/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Установка зависимостей backend (если есть package.json или requirements.txt)
if [ -f package.json ]; then
  npm install
fi

if [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi

# Установка зависимостей frontend
if [ -d "../Frontend" ]; then
  cd ../Frontend
  if [ -f package.json ]; then
    npm install
  fi
  cd -
fi

echo "Установка завершена!"