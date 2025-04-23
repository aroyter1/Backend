#!/bin/bash

# Добавляем ключ и репозиторий MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Установка MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Запускаем MongoDB
sudo systemctl start mongod

# Ставим MongoDB в автозапуск
sudo systemctl enable mongod

# Меняем конфиг
sudo tee /etc/mongod.conf > /dev/null <<EOF
net:
  port: 27777
  bindIp: 185.185.68.125
EOF

# Перезапуск MongoDB с новым конфигом
sudo systemctl restart mongod

# Разрешаем доступ с IP (настрой под себя)
sudo ufw allow from 94.20.141.134 to any port 27777 proto tcp

# Проверка статуса
sudo systemctl status mongod
