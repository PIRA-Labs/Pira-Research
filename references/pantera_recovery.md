# Pantera Recovery — Model Expiration & Gateway Restart

**Problem:** `hermes` crons failing with HTTP 404: `This model's free period has ended. Please select a different model to continue!`

**Root cause:** The model `tencent/hy3:free` expired. Node-01's Hermes persisted the expired model in `~/.hermes/config.yaml`.

## Recovery

### From Termux (preferred, outside the gateway process)

```bash
# Update model
sed -i 's/tencent\/hy3:free/laguna(xs-2.1):free/' ~/.hermes/config.yaml

# Restart gateway
pkill -f 'hermes gateway run'
nohup proot-distro login debian -- hermes gateway run >> ~/hermes-gateway.log 2>&1 </dev/null &
```

### From Mac via SSH direct to phone

```bash
ssh -p 8022 u0_a216@100.86.8.36 "<commands>"
```

### Verify

```bash
hermes portal status
grep 'default:' ~/.hermes/config.yaml
```

Expected output:
```
Model: ✓ using laguna(xs-2.1):free
  default: laguna(xs-2.1):free
```

## Pitfall: Self-Protection Block

**Do NOT** attempt `hermes gateway restart` from *inside* the running gateway (inside `proot-distro login debian`). The process will kill itself (SIGTERM propagates to child processes).

Always restart from:
- Termux shell (outside the proot session), or
- SSH direct to the phone user (`u0_a216`), bypassing the Hermes process.

## Recovery script

See `scripts/recover_pantera_gateway.sh` for an automated tool.

## Session log excerpt (2026-09-01)

```
hermes portal status
Model: ✗ using tencent/hy3:free (EXPIRED)

pkill: restart from Termux only
nohup: correct launch command
```