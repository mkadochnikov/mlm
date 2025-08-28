#!/bin/bash

echo "🔧 Fixing faker dependencies..."

# Method 1: Clean install with overrides
echo "Step 1: Cleaning npm cache and node_modules..."
rm -rf node_modules package-lock.json yarn.lock
npm cache clean --force

echo "Step 2: Installing with npm overrides..."
npm install --force --legacy-peer-deps

# If that fails, try alternative methods
if [ $? -ne 0 ]; then
    echo "❌ npm install failed, trying alternative method..."
    
    # Method 2: Install without scripts first
    echo "Step 3: Installing without scripts..."
    npm install --ignore-scripts --no-optional --force
    
    # Method 3: Manual faker installation
    echo "Step 4: Installing @faker-js/faker manually..."
    npm install @faker-js/faker --save --force
    
    # Method 4: Create symlink if needed
    if [ -d "node_modules" ] && [ ! -d "node_modules/faker" ]; then
        echo "Step 5: Creating faker symlink..."
        cd node_modules
        ln -sf @faker-js/faker faker
        cd ..
    fi
    
    # Method 5: Complete installation
    echo "Step 6: Completing installation..."
    npm install --force --legacy-peer-deps
fi

echo "✅ Faker fix completed!"
echo "🧪 Testing faker import..."
node -e "
try {
    const { faker } = require('@faker-js/faker');
    console.log('✅ @faker-js/faker works:', faker.name.firstName());
} catch (e) {
    console.log('❌ @faker-js/faker failed:', e.message);
}

try {
    const faker = require('faker');
    console.log('✅ faker alias works');
} catch (e) {
    console.log('⚠️  faker alias not available (this is OK)');
}
"

