
# Установка MongoDB Community Edition на Debian/Ubuntu

# Проверка, что скрипт выполняется на Ubuntu/Debian
if ! command -v lsb_release &> /dev/null; then
    echo "Ошибка: lsb_release не найден. Убедитесь, что вы используете Ubuntu или Debian."
    exit 1
fi

# Импорт ключа MongoDB
sudo mkdir -p /usr/share/keyrings
if ! curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb.gpg; then
    echo "Ошибка: не удалось импортировать ключ MongoDB."
    exit 1
fi

# Добавление репозитория MongoDB
MONGO_LIST="/etc/apt/sources.list.d/mongodb-org-6.0.list"
ARCH=$(dpkg --print-architecture)
DISTRO=$(lsb_release -cs)
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu ${DISTRO}/mongodb-org/6.0 multiverse" | sudo tee "${MONGO_LIST}"

# Обновление списка пакетов
if ! sudo apt-get update; then
    echo "Ошибка: не удалось обновить список пакетов. Проверьте подключение к интернету и репозитории."
    exit 1
fi

# Установка пакетов MongoDB
if ! sudo apt-get install -y mongodb-org; then
    echo "Ошибка: не удалось установить пакет mongodb-org."
    echo "Возможные причины: неподдерживаемая версия ОС, проблемы с репозиторием или отсутствует пакет."
    exit 1
fi

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
    echo "Попробуйте выполнить команду 'apt-cache search mongodb' и убедитесь, что пакет mongodb-org доступен."
    echo "Также проверьте, что вы используете поддерживаемую версию Ubuntu (например, 20.04 или 22.04)."
fi