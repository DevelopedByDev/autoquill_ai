#!/bin/bash

# Setup script for Hugging Face token for AutoQuill AI
echo "🤖 AutoQuill AI - Hugging Face Token Setup"
echo "==========================================="
echo ""

# Check if token is already set
if [ ! -z "$HUGGING_FACE_HUB_TOKEN" ]; then
    echo "✅ Hugging Face token is already configured!"
    echo "Token: ${HUGGING_FACE_HUB_TOKEN:0:10}..."
    echo ""
    read -p "Do you want to update it? (y/N): " update
    if [[ ! $update =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
fi

echo "To download WhisperKit models, you need a Hugging Face access token."
echo ""
echo "📝 Steps to get your token:"
echo "1. Go to https://huggingface.co/ and create a free account"
echo "2. Visit https://huggingface.co/settings/tokens"
echo "3. Click 'New token' and create a token with 'Read' permissions"
echo "4. Copy the token and paste it below"
echo ""

# Get token from user
read -s -p "🔑 Enter your Hugging Face token: " token
echo ""

if [ -z "$token" ]; then
    echo "❌ No token provided. Exiting..."
    exit 1
fi

# Add to shell profile
shell_profile=""
if [ -f ~/.zshrc ]; then
    shell_profile="$HOME/.zshrc"
elif [ -f ~/.bash_profile ]; then
    shell_profile="$HOME/.bash_profile"
elif [ -f ~/.bashrc ]; then
    shell_profile="$HOME/.bashrc"
else
    echo "⚠️  Could not detect shell profile. Please manually add:"
    echo "export HUGGING_FACE_HUB_TOKEN=\"$token\""
    echo "to your shell configuration file."
    exit 1
fi

# Check if token is already in profile
if grep -q "HUGGING_FACE_HUB_TOKEN" "$shell_profile"; then
    # Update existing token
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|export HUGGING_FACE_HUB_TOKEN=.*|export HUGGING_FACE_HUB_TOKEN=\"$token\"|" "$shell_profile"
    else
        # Linux
        sed -i "s|export HUGGING_FACE_HUB_TOKEN=.*|export HUGGING_FACE_HUB_TOKEN=\"$token\"|" "$shell_profile"
    fi
    echo "✅ Updated existing token in $shell_profile"
else
    # Add new token
    echo "" >> "$shell_profile"
    echo "# Hugging Face token for AutoQuill AI" >> "$shell_profile"
    echo "export HUGGING_FACE_HUB_TOKEN=\"$token\"" >> "$shell_profile"
    echo "✅ Added token to $shell_profile"
fi

# Set token for current session
export HUGGING_FACE_HUB_TOKEN="$token"

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📌 Next steps:"
echo "1. Restart your terminal or run: source $shell_profile"
echo "2. Launch AutoQuill AI"
echo "3. Go to Settings and try downloading a model"
echo ""
echo "💡 If you still have issues, check the README.md for additional troubleshooting steps." 