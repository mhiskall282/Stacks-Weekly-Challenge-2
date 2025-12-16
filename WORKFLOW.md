# 🚀 Step-by-Step Deployment & Transaction Testing

Complete workflow from local testing to mainnet deployment.

---

## Phase 1: Local Testing (5 minutes)

### Step 1: Verify Tests Pass
```bash
cd notepad-tasks-app
npm test
```

**Expected Output:**
```
✓ Tests: 19 passed (19)
✓ Test Files: 1 passed (1)
```

✅ **Verified**: Smart contract logic is correct

---

## Phase 2: Testnet Preparation (5 minutes)

### Step 1: Create Testnet Mnemonic

**Option A: Generate New**
```bash
# Using Stacks Wallet Browser Extension
# Or command line tool
stx generate
```

**Option B: Use Existing**
- Export from Stacks Wallet
- Use existing personal wallet
- Generate from standard BIP39 tool

### Step 2: Get Testnet STX

1. Go to: https://testnet-faucet.stacks.org/
2. Enter your account address (from mnemonic)
3. Receive 500 tSTX (free, no limits)
4. Wait ~2 minutes for confirmation

### Step 3: Configure Testnet Settings

Edit `settings/Testnet.toml`:
```toml
[network]
name = "testnet"
stacks_node_rpc_address = "https://api.testnet.hiro.so"
deployment_fee_rate = 10

[accounts.deployer]
mnemonic = "actual twelve word seed phrase goes here"
```

**⚠️ IMPORTANT**: 
- Never commit this file to git!
- Add to `.gitignore` if not already there
- Keep mnemonic secret

---

## Phase 3: Testnet Deployment (2 minutes)

### Step 1: Deploy Contract

```powershell
# Windows PowerShell
clarinet deployment apply --network testnet
```

Or:
```bash
# macOS/Linux
clarinet deployment apply --network testnet
```

### Step 2: Monitor Deployment

Watch for output like:
```
Deploying contract: notepad
Network: testnet
Endpoint: https://api.testnet.hiro.so
Status: Deploying...
```

Final output will show:
```
✅ Deployment Successful
Contract Address: SP1234567890ABCDEF.notepad
Transaction ID: 0xabcdef1234567890
Block: 1234
```

✅ **Save this contract address!** You'll need it for all transactions.

### Step 3: Verify on Explorer

1. Go to: https://explorer.hiro.so/?chain=testnet
2. Search for contract address: `SP1234567890ABCDEF.notepad`
3. You should see:
   - Transaction confirmed
   - Code deployed
   - Ready for use

---

## Phase 4: Test Transactions (10 minutes)

### Transaction 1: Create First Note

```bash
stx call-contract-fn \
  --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "create-note" \
  '"My First Task"' \
  '"Testing the Notepad contract deployment"' \
  '"high"'
```

**Expected Response:**
```
✓ Transaction submitted
✓ Transaction ID: 0x...
✓ Fee: 0.01 STX (10000 microstacks)
✓ Status: Pending
```

### Transaction 2: Check Contract Balance

```bash
stx call-read-only \
  --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "get-contract-balance"
```

**Expected Response:**
```
u10000  # Shows 0.01 STX collected
```

### Transaction 3: Get Builder Stats

```bash
stx call-read-only \
  --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "get-builder-stats" \
  "SP1234567890ABCDEF"
```

**Expected Response:**
```
{
  total-notes-created: u1,
  total-fees-paid: u10000,
  last-activity: u12345
}
```

### Transaction 4: Update Note

```bash
stx call-contract-fn \
  --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "update-note" \
  "u1" \
  '"Updated content after testing"' \
  '"in-progress"'
```

**Expected Response:**
```
✓ Transaction submitted
✓ Fee: 0.005 STX (5000 microstacks)
```

### Transaction 5: Complete Note

```bash
stx call-contract-fn \
  --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "complete-note" \
  "u1"
```

**Expected Response:**
```
✓ Transaction submitted
✓ Fee: 0 STX (no fee for completion)
```

### Transaction 6: View on Explorer

1. Go back to: https://explorer.hiro.so/?chain=testnet
2. Search for your contract address
3. Click on "Events" tab
4. You should see all Talent Protocol events:
   - NoteCreated
   - NoteUpdated  
   - NoteCompleted

✅ **Confirmed**: Contract is working perfectly!

---

## Phase 5: Batch Testing (Optional - 30 minutes)

### Create Multiple Notes Programmatically

Create file: `batch-test.js`
```javascript
const { StacksTestnet } = require('@stacks/network');
const { broadcastTransaction, stringAsciiCV, uintCV } = require('@stacks/transactions');

const network = new StacksTestnet();
const CONTRACT = 'SP1234567890ABCDEF.notepad';
const NOTES_TO_CREATE = 10;

async function createBatch() {
  for (let i = 1; i <= NOTES_TO_CREATE; i++) {
    const txOptions = {
      contractAddress: CONTRACT.split('.')[0],
      contractName: 'notepad',
      functionName: 'create-note',
      functionArgs: [
        stringAsciiCV(`Task ${i}`),
        stringAsciiCV(`Testing batch creation`),
        stringAsciiCV(['high', 'medium', 'low'][i % 3])
      ],
      network,
      // Add your signing/auth here
    };
    
    console.log(`Creating note ${i}...`);
    // Send transaction (requires full signing setup)
  }
}

createBatch();
```

Run:
```bash
node batch-test.js
```

---

## Phase 6: Mainnet Preparation (Same Day or Next Day)

### Once Testnet is Successful:

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

### Step 3: Save Mainnet Contract Address

Will look like:
```
Contract Address: SP1234567890ABCDEF.notepad  # Different from testnet!
```

### Step 4: Fund Mainnet Account

You'll need actual STX for mainnet:
- Buy from exchange
- Receive as payment
- Use existing balance

Recommended minimum: 1 STX to start (for deployment + transactions)

---

## Phase 7: Mainnet Transactions (Challenge Phase)

### Strategy for 1000 STX Challenge

#### Week 1: Small Scale Testing
- Create 100 notes
- Cost: 1 STX
- Verify everything works on mainnet

#### Week 2-3: Scaling Phase
- Create 1000+ notes
- Cost: ~10 STX
- Monitor Talent Protocol rewards

#### Week 4: Optimization
- Analyze builder stats
- Adjust activity patterns
- Maximize final earnings

### Monitor Progress

Check builder stats daily:
```bash
stx call-read-only \
  --network mainnet \
  "SP1234567890ABCDEF.notepad" \
  "get-builder-stats" \
  "SPYOURADDRESS"
```

Track on mainnet explorer:
https://explorer.hiro.so/ (no ?chain=testnet)

---

## 📊 Expected Gas Costs

| Operation | Cost | 1000x Cost |
|-----------|------|-----------|
| Deploy | ~0.1-0.2 STX | - |
| Create Note | 0.01 STX | 10 STX |
| Update Note | 0.005 STX | 5 STX |
| Complete/Delete | 0 STX | 0 STX |
| **Total ~1000 notes** | - | **~15 STX** |

---

## 🎯 Success Indicators

### Testnet ✅
- [ ] Tests passing locally
- [ ] Contract deployed on testnet
- [ ] Contract visible on explorer
- [ ] First transaction successful
- [ ] Talent Protocol events showing
- [ ] Builder stats updating

### Mainnet ✅
- [ ] Contract deployed on mainnet
- [ ] 100+ transactions confirmed
- [ ] Builder rewards accumulating
- [ ] Activity tracking working
- [ ] No errors in transactions
- [ ] Contract balance growing

---

## 🚨 Troubleshooting

### Deployment Fails

**Error**: "mnemonic is required"
```
Fix: Update settings/Testnet.toml with valid mnemonic
```

**Error**: "Insufficient balance"
```
Fix: Get more tSTX from faucet (testnet) or buy STX (mainnet)
```

**Error**: "Contract already exists"
```
Fix: Contract already deployed, use existing address
```

### Transaction Fails

**Error**: "ERR_UNAUTHORIZED"
```
Fix: Only note owner can modify - use correct account
```

**Error**: "ERR_NOT_ENOUGH_STX"
```
Fix: Account balance too low, need more STX
```

**Error**: "Contract not found"
```
Fix: Wrong contract address or chain (testnet vs mainnet)
```

---

## 📝 Quick Command Reference

### Testnet Deployment
```bash
clarinet deployment apply --network testnet
```

### Create Note
```bash
stx call-contract-fn --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "create-note" \
  '"Title"' '"Content"' '"priority"'
```

### Check Balance
```bash
stx call-read-only --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "get-contract-balance"
```

### View Builder Stats
```bash
stx call-read-only --network testnet \
  "SP1234567890ABCDEF.notepad" \
  "get-builder-stats" "SP1234567890ABCDEF"
```

---

## ✅ You're Ready!

Follow these phases in order:
1. ✅ Local testing
2. ✅ Testnet prep & config
3. ✅ Deploy to testnet
4. ✅ Test transactions
5. ✅ Batch testing (optional)
6. ✅ Mainnet prep
7. ✅ Mainnet deployment
8. ✅ Challenge phase

**Estimated Total Time**: 2-3 hours setup, then continuous testing/scaling

Good luck with the 1000 STX challenge! 🚀

---

**Need Help?**
- Review README-DEPLOYMENT.md
- Check QUICK-REFERENCE.md  
- View project logs
- Check explorer: https://explorer.hiro.so/
