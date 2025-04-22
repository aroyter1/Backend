#!/bin/bash

# Удалим старые записи
sudo rm -f /etc/apt/sources.list.d/mongodb*.list

# Обновим ключи и подключим официальный репозиторий MongoDB 7.0
sudo apt update && sudo apt install -y curl gnupg

curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg --dearmor | sudo tee /usr/share/keyrings/mongodb-org-7.0.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/mongodb-org-7.0.gpg] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Устанавливаем MongoDB
sudo apt update && sudo apt install -y mongodb-org

# Запускаем MongoDB и добавляем в автозагрузку
sudo systemctl enable --now mongod

# Проверим статус
sudo systemctl status mongod