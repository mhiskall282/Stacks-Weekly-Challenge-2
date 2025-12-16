# Testnet Deployment Script for Notepad Contract (PowerShell)
# This script helps deploy the contract to Stacks testnet

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Notepad Contract - Testnet Deployment" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if clarinet is installed
$clarinettst = Get-Command clarinet -ErrorAction SilentlyContinue
if (-not $clarinet) {
    Write-Host "❌ Clarinet is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

Write-Host "✓ Clarinet is installed" -ForegroundColor Green
Write-Host ""

# Check network connectivity
Write-Host "Checking testnet connectivity..." -ForegroundColor Yellow
$testnetCheck = $null
try {
    $testnetCheck = Invoke-WebRequest -Uri "https://api.testnet.hiro.so/v2/info" -TimeoutSec 5 -ErrorAction SilentlyContinue
}
catch {
    # Silently fail if connection check fails
}

if ($testnetCheck) {
    Write-Host "✓ Connected to Stacks testnet" -ForegroundColor Green
} else {
    Write-Host "⚠️  Could not connect to testnet. Please check your internet connection." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Setup Instructions:" -ForegroundColor Cyan
Write-Host "1. Get a testnet mnemonic (create or use existing)" 
Write-Host "2. Ensure testnet account is funded with tSTX from faucet:"
Write-Host "   https://testnet-faucet.stacks.org/"
Write-Host ""
Write-Host "3. Update settings/Testnet.toml with your mnemonic:"
Write-Host "   [accounts.deployer]"
Write-Host "   mnemonic = `"your twelve word seed phrase here`""
Write-Host ""

# Check if Testnet.toml exists and has placeholder
$testnetToml = Get-Content settings/Testnet.toml -Raw
if ($testnetToml -match "YOUR PRIVATE TESTNET MNEMONIC") {
    Write-Host "⚠️  Please update settings/Testnet.toml with your testnet mnemonic first!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run:"
    Write-Host "  # Edit settings/Testnet.toml and replace the placeholder"
    Write-Host "  notepad settings/Testnet.toml"
    exit 1
}

Write-Host "✓ Testnet.toml is configured" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Deploying to testnet..." -ForegroundColor Cyan
Write-Host ""

clarinet deployment apply --network testnet

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Contract Summary:" -ForegroundColor Cyan
Write-Host "  - Network: Testnet"
Write-Host "  - Contract: notepad"
Write-Host "  - Creation Fee: 0.01 STX"
Write-Host "  - Update Fee: 0.005 STX"
Write-Host "  - Talent Protocol: Enabled"
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Check deployment logs above for contract address"
Write-Host "  2. Test transactions using the contract address"
Write-Host "  3. Monitor activity on: https://explorer.hiro.so/"
Write-Host ""
