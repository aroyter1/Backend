

# Установка MongoDB
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/debian $(lsb_release -cs)/mongodb-org/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

echo "Установка MongoDB завершена!"