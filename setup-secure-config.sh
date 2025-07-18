#!/bin/bash

# Secure API Key Setup Script
# This script helps set up the secure configuration for production API keys

echo "🔑 Flowers App - Secure API Key Setup"
echo "======================================"
echo

# Check if SecureConfig.swift already exists
if [ -f "Flowers/Configuration/SecureConfig.swift" ]; then
    echo "⚠️  SecureConfig.swift already exists!"
    echo "   This file contains your production API keys."
    echo "   Do you want to overwrite it? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled."
        exit 0
    fi
fi

# Copy template to create SecureConfig.swift
echo "📝 Creating SecureConfig.swift from template..."
cp "Flowers/Configuration/SecureConfig.swift.template" "Flowers/Configuration/SecureConfig.swift"

if [ $? -eq 0 ]; then
    echo "✅ SecureConfig.swift created successfully!"
    echo
    echo "🔧 NEXT STEPS:"
    echo "1. Open Flowers/Configuration/SecureConfig.swift"
    echo "2. Replace 'REPLACE_WITH_YOUR_OPENAI_KEY' with your actual OpenAI API key"
    echo "3. Replace 'REPLACE_WITH_YOUR_FAL_KEY' with your actual FAL AI API key"
    echo "4. Save the file"
    echo
    echo "⚠️  IMPORTANT:"
    echo "   - SecureConfig.swift is ignored by git and will never be committed"
    echo "   - Keep your API keys secure and never share them"
    echo "   - Users of your app will use YOUR API keys automatically"
    echo
    echo "🎯 After setup, users will get proper AI-generated flowers!"
else
    echo "❌ Failed to create SecureConfig.swift"
    echo "   Please manually copy SecureConfig.swift.template to SecureConfig.swift"
fi