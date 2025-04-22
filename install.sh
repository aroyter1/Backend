
# Установка MongoDB Community Edition на Debian

# Проверка, что скрипт выполняется на Debian
if ! command -v lsb_release &> /dev/null; then
    echo "Ошибка: lsb_release не найден. Убедитесь, что вы используете Debian."
    exit 1
fi

# Определение дистрибутива и версии
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
ARCH=$(dpkg --print-architecture)

# Проверка поддерживаемых версий Debian
if [[ "$DISTRO" != "debian" ]]; then
    echo "Ошибка: данный скрипт поддерживает только Debian."
    exit 1
fi

if [[ "$CODENAME" != "bullseye" && "$CODENAME" != "bookworm" ]]; then
    echo "Ошибка: поддерживаются только Debian 11 (bullseye) и 12 (bookworm)."
    echo "Ваш дистрибутив: $CODENAME"
    exit 1
fi

# Импорт ключа MongoDB (перезаписывать ключ не нужно, если он уже есть)
KEYRING_PATH="/usr/share/keyrings/mongodb.gpg"
if [ ! -f "$KEYRING_PATH" ]; then
    sudo mkdir -p /usr/share/keyrings
    if ! curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o "$KEYRING_PATH"; then
        echo "Ошибка: не удалось импортировать ключ MongoDB."
        exit 1
    fi
else
    echo "Ключ MongoDB уже существует: $KEYRING_PATH"
fi

# Добавление репозитория MongoDB (перезаписывать файл только если его нет)
MONGO_LIST="/etc/apt/sources.list.d/mongodb-org-6.0.list"
REPO_LINE="deb [arch=${ARCH} signed-by=${KEYRING_PATH}] https://repo.mongodb.org/apt/debian ${CODENAME}/mongodb-org/6.0 main"
if ! grep -Fxq "$REPO_LINE" "$MONGO_LIST" 2>/dev/null; then
    echo "$REPO_LINE" | sudo tee "$MONGO_LIST"
else
    echo "Репозиторий MongoDB уже добавлен: $MONGO_LIST"
fi

# Проверка содержимого файла репозитория
if ! grep -Fxq "$REPO_LINE" "$MONGO_LIST"; then
    echo "Ошибка: строка репозитория не найдена в $MONGO_LIST"
    echo "Текущее содержимое файла:"
    cat "$MONGO_LIST"
    exit 1
fi

# Проверка доступности репозитория
if ! curl -fsSL "https://repo.mongodb.org/apt/debian/dists/${CODENAME}/mongodb-org/6.0/Release" > /dev/null; then
    echo "Ошибка: репозиторий MongoDB для ${CODENAME} не найден или недоступен."
    echo "Проверьте, что вы используете поддерживаемую версию Debian (11 bullseye или 12 bookworm)."
    echo "Возможно, для вашей версии Debian ещё нет пакетов MongoDB 6.0."
    echo "Проверьте наличие пакетов вручную: https://repo.mongodb.org/apt/debian/dists/${CODENAME}/mongodb-org/6.0/"
    exit 1
fi

# Обновление списка пакетов
if ! sudo apt-get update; then
    echo "Ошибка: не удалось обновить список пакетов. Проверьте подключение к интернету и репозитории."
    exit 1
fi

# Проверка наличия пакета mongodb-org в репозитории
if ! apt-cache policy mongodb-org | grep -q 'Candidate:'; then
    echo "Ошибка: пакет mongodb-org не найден в репозиториях apt."
    echo "Возможные причины:"
    echo "  - Для вашей версии Debian (${CODENAME}) ещё нет пакета mongodb-org 6.0."
    echo "  - Репозиторий MongoDB не добавлен или недоступен."
    echo "  - Проверьте содержимое файла ${MONGO_LIST} и наличие файла ${KEYRING_PATH}."
    echo "  - Проверьте вручную: https://repo.mongodb.org/apt/debian/dists/${CODENAME}/mongodb-org/6.0/"
    echo ""
    echo "Проверьте, что файл ${MONGO_LIST} содержит строку:"
    echo "  $REPO_LINE"
    echo ""
    echo "Проверьте, что ключ существует:"
    echo "  ls -l ${KEYRING_PATH}"
    echo ""
    echo "Если проблема сохраняется, попробуйте удалить файл ${MONGO_LIST} и повторить запуск скрипта."
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
    echo "Также проверьте, что вы используете поддерживаемую версию Debian (например, 11 или 12)."
fi