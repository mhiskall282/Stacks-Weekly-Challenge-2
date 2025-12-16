#!/bin/bash
# Testnet Deployment Script for Notepad Contract
# This script helps deploy the contract to Stacks testnet

set -e

echo "================================"
echo "Notepad Contract - Testnet Deployment"
echo "================================"
echo ""

# Check if clarinet is installed
if ! command -v clarinet &> /dev/null; then
    echo "❌ Clarinet is not installed. Please install it first."
    exit 1
fi

echo "✓ Clarinet is installed"
echo ""

# Check network connectivity
echo "Checking testnet connectivity..."
if curl -s https://api.testnet.hiro.so/v2/info --max-time 5 > /dev/null; then
    echo "✓ Connected to Stacks testnet"
else
    echo "⚠️  Could not connect to testnet. Please check your internet connection."
fi

echo ""
echo "📋 Setup Instructions:"
echo "1. Get a testnet mnemonic (create or use existing)"
echo "2. Ensure testnet account is funded with tSTX from faucet:"
echo "   https://testnet-faucet.stacks.org/"
echo ""
echo "3. Update settings/Testnet.toml with your mnemonic:"
echo "   [accounts.deployer]"
echo "   mnemonic = \"your twelve word seed phrase here\""
echo ""

# Check if Testnet.toml exists
if grep -q "YOUR PRIVATE TESTNET MNEMONIC" settings/Testnet.toml; then
    echo "⚠️  Please update settings/Testnet.toml with your testnet mnemonic first!"
    echo ""
    echo "Run:"
    echo "  # Edit settings/Testnet.toml and replace the placeholder"
    echo "  nano settings/Testnet.toml"
    exit 1
fi

echo "✓ Testnet.toml is configured"
echo ""
echo "🚀 Deploying to testnet..."
echo ""

clarinet deployment apply --network testnet

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Contract Summary:"
echo "  - Network: Testnet"
echo "  - Contract: notepad"
echo "  - Creation Fee: 0.01 STX"
echo "  - Update Fee: 0.005 STX"
echo "  - Talent Protocol: Enabled"
echo ""
echo "📝 Next Steps:"
echo "  1. Check deployment logs above for contract address"
echo "  2. Test transactions using the contract address"
echo "  3. Monitor activity on: https://explorer.hiro.so/"
echo ""
