
# Установка MongoDB Community Edition на Debian GNU/Linux 12 (bookworm)
set -e

# Проверка, что скрипт выполняется на Debian GNU/Linux 12
if ! command -v lsb_release &> /dev/null; then
    echo "Ошибка: lsb_release не найден. Убедитесь, что вы используете Debian GNU/Linux."
    exit 1
fi

DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
ARCH=$(dpkg --print-architecture)

if [[ "$DISTRO" != "debian" ]]; then
    echo "Ошибка: данный скрипт поддерживает только Debian GNU/Linux."
    exit 1
fi

if [[ "$CODENAME" != "bookworm" ]]; then
    echo "Ошибка: поддерживается только Debian GNU/Linux 12 (bookworm)."
    echo "Ваш дистрибутив: $CODENAME"
    exit 1
fi

# Импорт ключа MongoDB (если ещё не импортирован)
KEYRING_PATH="/usr/share/keyrings/mongodb-server-6.0.gpg"
if [ ! -f "$KEYRING_PATH" ]; then
    sudo mkdir -p /usr/share/keyrings
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg --dearmor -o "$KEYRING_PATH"
fi

# Добавление репозитория MongoDB (только если ещё не добавлен)
MONGO_LIST="/etc/apt/sources.list.d/mongodb-org-6.0.list"
REPO_LINE="deb [ arch=${ARCH} signed-by=${KEYRING_PATH} ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/6.0 main"

# Проверяем, есть ли уже нужная строка в файле, иначе добавляем
if [ ! -f "$MONGO_LIST" ] || ! grep -Fxq "$REPO_LINE" "$MONGO_LIST"; then
    echo "$REPO_LINE" | sudo tee "$MONGO_LIST" > /dev/null
fi

# Обновление списка пакетов
sudo apt-get update

# Проверка наличия пакета mongodb-org в списке доступных
if ! apt-cache policy mongodb-org | grep -q 'Candidate:'; then
    echo "Ошибка: пакет mongodb-org не найден в репозитории. Проверьте правильность добавления репозитория и ключа."
    exit 1
fi

# Установка пакетов MongoDB
sudo apt-get install -y mongodb-org

# Запуск и включение службы mongod
sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod --no-pager

echo "Установка и запуск MongoDB завершены!"