
# Установка MongoDB Community Edition на Debian/Ubuntu

# Импорт ключа MongoDB
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb.gpg

# Добавление репозитория MongoDB
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Обновление списка пакетов
sudo apt-get update

# Установка пакетов MongoDB
sudo apt-get install -y mongodb-org

# Проверка наличия службы mongod
if systemctl list-unit-files | grep -q mongod.service; then
    echo "MongoDB установлен. Запуск службы mongod..."
    sudo systemctl enable mongod
    sudo systemctl start mongod
    sudo systemctl status mongod --no-pager
    echo "Установка и запуск MongoDB завершены!"
else
    echo "Ошибка: служба mongod не найдена. Проверьте, что пакет mongodb-org установлен корректно."
    echo "Возможные причины: неподдерживаемая версия ОС или проблемы с репозиторием."
fi