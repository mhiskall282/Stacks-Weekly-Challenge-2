# Notepad Smart Contract - Deployment & Testing Guide

## 📋 Overview

The Notepad contract is a Talent Protocol-compliant smart contract for managing notes/tasks on the Stacks blockchain. With ultra-low fees (0.01 STX per note), it's perfect for the 1000 STX challenge.

### Key Features
- ✅ **Low Fees**: 0.01 STX per note creation, 0.005 STX per update
- ✅ **Talent Protocol Compliant**: Full builder activity tracking
- ✅ **Secure**: Only note owners can modify/delete notes
- ✅ **Audit Trail**: Soft delete with complete history
- ✅ **Transaction Verified**: All operations emit events

## 🔧 Contract Configuration

### Current Settings
```
Creation Fee: 0.01 STX (10,000 microstacks)
Update Fee:   0.005 STX (5,000 microstacks)
Clarity:      3.0
Status:       19/19 tests passing ✅
```

### Quick Math for 1000 STX Challenge
- 1000 notes × 0.01 STX = **10 STX in fees**
- Talent Protocol rewards can exceed this cost significantly!

---

## 🚀 Deployment to Testnet

### Step 1: Prepare Your Testnet Account

#### Option A: Generate New Account
```bash
# Get testnet STX from faucet
# https://testnet-faucet.stacks.org/

# Generate a new mnemonic (or use existing)
```

#### Option B: Use Existing Account
```bash
# Export your mnemonic from Stacks Wallet or other source
```

### Step 2: Configure Testnet Settings

Edit `settings/Testnet.toml`:
```toml
[network]
name = "testnet"
stacks_node_rpc_address = "https://api.testnet.hiro.so"
deployment_fee_rate = 10

[accounts.deployer]
mnemonic = "your twelve word seed phrase here"
```

### Step 3: Deploy to Testnet

**PowerShell (Windows):**
```powershell
# Run the deployment script
.\deploy-testnet.ps1

# Or manual deployment
clarinet deployment apply --network testnet
```

**Bash (macOS/Linux):**
```bash
# Run the deployment script
bash deploy-testnet.sh

# Or manual deployment
clarinet deployment apply --network testnet
```

### Step 4: Verify Deployment

Look for output like:
```
✅ Deployment complete!
📊 Contract address: SP1234567890ABCDEF.notepad
```

---

## 🧪 Testing Transactions on Testnet

### Using Stacks CLI

#### 1. Create a Note
```bash
stx call-contract-fn \
  --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "create-note" \
  '"My Task"' \
  '"Important description"' \
  '"high"'
```

#### 2. Query Builder Stats
```bash
stx call-read-only \
  --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "get-builder-stats" \
  "SP1234567890ABCDEF"
```

#### 3. Check Contract Balance
```bash
stx call-read-only \
  --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "get-contract-balance"
```

#### 4. Get Total Fees Collected
```bash
stx call-read-only \
  --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "get-total-fees"
```

### Using JavaScript/TypeScript SDK

```typescript
import { StacksTestnet } from '@stacks/network';
import { ContractCallOptions, broadcastTransaction } from '@stacks/transactions';

const network = new StacksTestnet();

const options: ContractCallOptions = {
  contractAddress: 'SP1234567890ABCDEF',
  contractName: 'notepad',
  functionName: 'create-note',
  functionArgs: [stringAsciiCV('Task'), stringAsciiCV('Details'), stringAsciiCV('high')],
  network,
  // ... more options
};

await broadcastTransaction(options);
```

### Using Web Explorer
1. Go to https://explorer.hiro.so/?chain=testnet
2. Search for contract address: `SP1234567890ABCDEF.notepad`
3. View all transactions and events in real-time

---

## 📈 Scaling to 1000+ Transactions

### Strategy for Challenge Success

1. **Batch Creation Script** (recommended)
   - Create a script to generate notes programmatically
   - Space out transactions to avoid network congestion
   - Monitor gas fees and builder rewards

2. **Optimal Timing**
   - Deploy during low-congestion periods
   - Monitor testnet activity at https://explorer.hiro.so/
   - Spread transactions over time for better rewards

3. **Fee Efficiency**
   - Current: 0.01 STX per note = very competitive
   - Total for 1000 notes: only 10 STX in fees
   - Potential earnings from Talent Protocol rewards far exceed fees

### Sample Batch Script (JavaScript)
```javascript
const { StacksTestnet } = require('@stacks/network');
const { broadcastTransaction, stringAsciiCV } = require('@stacks/transactions');

const network = new StacksTestnet();
const NOTES_TO_CREATE = 1000;
const DELAY_BETWEEN_TXNS = 500; // milliseconds

async function createBulkNotes() {
  for (let i = 0; i < NOTES_TO_CREATE; i++) {
    const note = `Task ${i + 1}`;
    const description = `Created in batch testing for challenge`;
    const priority = ['high', 'medium', 'low'][i % 3];

    // Build transaction
    const txOptions = {
      contractAddress: 'SP1234567890ABCDEF',
      contractName: 'notepad',
      functionName: 'create-note',
      functionArgs: [
        stringAsciiCV(note),
        stringAsciiCV(description),
        stringAsciiCV(priority)
      ],
      network,
      // ... signing details
    };

    // Send transaction
    await broadcastTransaction(txOptions);
    
    console.log(`Created note ${i + 1}/${NOTES_TO_CREATE}`);
    
    // Wait before next transaction
    await new Promise(resolve => setTimeout(resolve, DELAY_BETWEEN_TXNS));
  }
}

createBulkNotes().catch(console.error);
```

---

## 📊 Mainnet Deployment

### Step 1: Update Mainnet Configuration

Edit `settings/Mainnet.toml`:
```toml
[network]
name = "mainnet"
stacks_node_rpc_address = "https://api.hiro.so"
deployment_fee_rate = 10

[accounts.deployer]
mnemonic = "your mainnet seed phrase here"
```

### Step 2: Deploy to Mainnet

```bash
clarinet deployment apply --network mainnet
```

### Step 3: Monitor on Mainnet

- Block Explorer: https://explorer.hiro.so/
- Check contract address from deployment output
- Monitor builder stats and fee collection

---

## 🔐 Security Notes

1. **Never commit mnemonics** to git or public repositories
2. **Always use testnet first** to verify transactions
3. **Keep deployer wallet funded** but not with large amounts
4. **Verify contract addresses** before sending transactions
5. **Test fee calculations** before scaling to production

---

## 📋 Contract Functions

### Public Functions (Cost STX)

| Function | Fee | Notes |
|----------|-----|-------|
| `create-note` | 0.01 STX | Create new note, tracks builder activity |
| `update-note` | 0.005 STX | Update note content/status |
| `complete-note` | 0 STX | Mark note as completed |
| `delete-note` | 0 STX | Soft delete (audit trail preserved) |

### Read-Only Functions (Free)

- `get-note` - Retrieve specific note
- `get-user-notes` - List user's note IDs
- `get-user-note-count` - Count user's notes
- `get-total-notes` - Total notes created
- `get-total-fees` - Total fees collected
- `get-total-transactions` - Transaction count
- `get-contract-balance` - Contract STX balance
- `get-builder-stats` - Talent Protocol stats
- `get-active-note-count` - Active notes (not deleted)

---

## 🎯 Earning 1000 STX

### The Math
- **Contract fee earnings**: Low but consistent
- **Talent Protocol rewards**: Primary earnings source
- **Builder activity tracking**: Every transaction counts
- **Challenge multipliers**: Potential bonus rewards

### Optimization Tips
1. Consistent activity (daily transactions better than bursts)
2. Variety of operations (create, update, complete mix)
3. Multiple accounts (if allowed) to increase total activity
4. Monitor leaderboards at builder.hiro.so

---

## 🐛 Troubleshooting

### Deployment Issues

**Error: "mnemonic is required"**
- Solution: Update settings/Testnet.toml with valid mnemonic

**Error: "Insufficient balance"**
- Solution: Request more tSTX from testnet faucet

**Error: "Contract already exists"**
- Solution: Update contract name or check existing deployment

### Transaction Issues

**Error: "ERR_UNAUTHORIZED"**
- Cause: Trying to modify note you don't own
- Solution: Verify caller is note owner

**Error: "ERR_NOT_ENOUGH_STX"**
- Cause: Account balance too low for fee
- Solution: Fund account with more STX

---

## 📚 Additional Resources

- **Stacks Docs**: https://docs.stacks.co/
- **Clarity Docs**: https://docs.stacks.co/clarity
- **Talent Protocol**: https://talentprotocol.com/
- **Hiro Explorer**: https://explorer.hiro.so/
- **Community Chat**: https://discord.gg/stacks

---

## ✅ Deployment Checklist

- [ ] Testnet mnemonic configured in settings/Testnet.toml
- [ ] Account funded with testnet STX
- [ ] All 19 unit tests passing (`npm test`)
- [ ] Deployment script ready (`./deploy-testnet.ps1`)
- [ ] Network connectivity verified
- [ ] Contract deployed to testnet
- [ ] Test transactions created and verified
- [ ] Mainnet configuration prepared
- [ ] Ready for bulk testing

---

**Last Updated**: 2025-12-16  
**Contract Version**: 1.0  
**Status**: Production Ready ✅
