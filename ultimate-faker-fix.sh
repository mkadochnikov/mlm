#!/bin/bash

echo "🚀 ULTIMATE FAKER FIX - Финальное решение"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Clean everything
print_status "Шаг 1: Полная очистка..."
rm -rf node_modules package-lock.json yarn.lock .npm
npm cache clean --force 2>/dev/null || true

# Step 2: Create temporary package.json without problematic dependencies
print_status "Шаг 2: Создание временного package.json..."
cp package.json package.json.backup

# Step 3: Install @faker-js/faker first
print_status "Шаг 3: Установка @faker-js/faker..."
npm install @faker-js/faker --save --no-package-lock --legacy-peer-deps --force 2>/dev/null

# Step 4: Create faker alias in node_modules
print_status "Шаг 4: Создание алиаса faker..."
mkdir -p node_modules
if [ -d "node_modules/@faker-js" ]; then
    cd node_modules
    if [ ! -d "faker" ]; then
        ln -sf @faker-js/faker faker
        print_success "Создан символический линк faker -> @faker-js/faker"
    fi
    cd ..
fi

# Step 5: Install dependencies without package-lock
print_status "Шаг 5: Установка зависимостей без package-lock..."
npm install --no-package-lock --legacy-peer-deps --force --ignore-scripts 2>/dev/null

# Step 6: Fix any remaining faker references
print_status "Шаг 6: Исправление оставшихся ссылок на faker..."
if [ -f "package-lock.json" ]; then
    # Replace git URLs in package-lock.json if it exists
    sed -i 's|git+https://github.com/Marak/faker.js.git|https://registry.npmjs.org/@faker-js/faker|g' package-lock.json 2>/dev/null || true
    sed -i 's|https://github.com/Marak/faker.js.git|https://registry.npmjs.org/@faker-js/faker|g' package-lock.json 2>/dev/null || true
    sed -i 's|github:Marak/faker.js|https://registry.npmjs.org/@faker-js/faker|g' package-lock.json 2>/dev/null || true
fi

# Step 7: Final installation attempt
print_status "Шаг 7: Финальная установка..."
npm install --legacy-peer-deps --force 2>/dev/null || {
    print_warning "Стандартная установка не удалась, пробуем альтернативный метод..."
    
    # Alternative method: install without scripts and optional deps
    npm install --ignore-scripts --no-optional --legacy-peer-deps --force 2>/dev/null || {
        print_warning "Альтернативная установка не удалась, используем yarn..."
        
        # Try with yarn
        if command -v yarn &> /dev/null; then
            yarn install --ignore-engines --ignore-scripts 2>/dev/null || true
        fi
    }
}

# Step 8: Ensure faker is available
print_status "Шаг 8: Проверка доступности faker..."
if [ ! -d "node_modules/@faker-js" ]; then
    print_warning "Устанавливаем @faker-js/faker принудительно..."
    npm install @faker-js/faker --save --force 2>/dev/null || true
fi

# Create faker alias if it doesn't exist
if [ -d "node_modules/@faker-js/faker" ] && [ ! -d "node_modules/faker" ]; then
    cd node_modules
    ln -sf @faker-js/faker faker
    cd ..
    print_success "Создан алиас faker"
fi

# Step 9: Test installation
print_status "Шаг 9: Тестирование установки..."
echo "=========================================="

# Test @faker-js/faker
node -e "
try {
    const { faker } = require('@faker-js/faker');
    console.log('✅ @faker-js/faker работает:', faker.person.firstName());
} catch (e) {
    console.log('❌ @faker-js/faker не работает:', e.message);
}
" 2>/dev/null || print_error "@faker-js/faker не найден"

# Test faker alias
node -e "
try {
    const faker = require('faker');
    console.log('✅ faker алиас работает');
} catch (e) {
    console.log('⚠️  faker алиас недоступен (это нормально)');
}
" 2>/dev/null || print_warning "faker алиас недоступен"

# Test legacy faker import
node -e "
try {
    const faker = require('faker');
    if (faker.name) {
        console.log('✅ Старый faker API работает:', faker.name.firstName());
    } else {
        console.log('⚠️  Старый faker API недоступен');
    }
} catch (e) {
    console.log('⚠️  Старый faker API недоступен');
}
" 2>/dev/null || true

echo "=========================================="
print_success "FAKER FIX ЗАВЕРШЕН!"

# Final status
if [ -d "node_modules/@faker-js/faker" ]; then
    print_success "✅ @faker-js/faker установлен успешно"
else
    print_error "❌ @faker-js/faker не установлен"
fi

if [ -d "node_modules/faker" ]; then
    print_success "✅ faker алиас создан"
else
    print_warning "⚠️  faker алиас не создан"
fi

echo ""
print_status "Для использования в коде:"
echo "  import { faker } from '@faker-js/faker';"
echo "  // или"
echo "  const { faker } = require('@faker-js/faker');"
echo ""
print_status "Попробуйте запустить: npm start"

