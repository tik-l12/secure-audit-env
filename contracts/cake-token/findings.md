# Audit Notes: CAKE Token (PancakeSwap)

**Date:** 2026-07-17
**Contract:** CakeToken.sol
**Compiler:** solc 0.6.12
**Tool:** Slither 0.11.5

## Summary

First practice scan using the audit environment. 101 detectors run,
20 results found — all low severity or informational. No critical
or high-severity issues identified, consistent with CAKE being a
mature, previously audited contract.

## Findings

### 1. Low-level call (Informational)
`target.call{value: weiValue}(data)` — bypasses some of Solidity's
built-in safety checks (like automatic revert on failure). Worth a
manual look in any contract, but implemented safely here with an
explicit success check.

### 2. Naming convention (Informational)
Parameters like `_to` and `_amount` in `mint()` don't follow Slither's
preferred mixedCase style. Cosmetic only, no security impact.

### 3. Redundant statement (Informational)
A standalone `this;` expression with no effect — likely leftover
boilerplate from the Context base contract. No security impact.

### 4. Immutable state suggestion (Informational / Gas)
`_decimals` could be declared `immutable` for gas savings, since it's
only set once. Optimization suggestion, not a vulnerability.

## Takeaways
- Environment (Foundry + Slither via solc-select) confirmed working
  end-to-end on a real, verified BSC contract.
- Next: try a less battle-tested contract to compare finding severity
  and volume against this baseline.
  ## Cross-Referenced Static Analysis (Slither + Aderyn)

**Date:** 2026-07-18
**Tools:** Slither 0.11.5, Aderyn 0.6.8

Ran Aderyn as a second static analyzer to cross-reference against the
original Slither scan. No high or medium severity findings from either
tool — consistent with CAKE being a mature, previously audited contract.

### Convergent findings (flagged by both tools)

1. **Centralization risk** — 5 instances of privileged owner functions
   (mint, critical settings) with no additional restrictions beyond
   `onlyOwner`. Standard finding: contract security fully depends on
   the owner key's security. Not a code bug, but a documented trust
   assumption.

2. **Dead/unused code** — internal utilities like `_msgData()` and
   `_burnFrom()`, plus single-use math wrappers, are present but never
   called. Minor unnecessary deployment gas cost, no security impact.

3. **Gas/visibility optimizations** — `_name`, `_symbol`, `_decimals`
   could be `immutable`; several owner-only functions could be `external`
   instead of `public`. Optimization suggestions, no security impact.

### Aderyn-specific finding

**Signature malleability in `delegateBySig()` (line 964)** — uses raw
`ecrecover()` instead of a wrapped library (e.g. OpenZeppelin's ECDSA.sol).
Raw `ecrecover` allows a signature to be resubmitted in an altered but
still-valid form. However, `delegateBySig()` tracks a nonce
(`nonce == nonces[signatory]++`, line 964 area) which mitigates replay
risk in practice. Documented as a best-practice note rather than an
active vulnerability, given the nonce protection already in place.

### Takeaway

Static triage across two tools found no logic bugs (no overflow,
reentrancy, or broken inheritance). Remaining risk is centralization
(trust in the owner key) — which static tools can flag but not judge
the real-world severity of; that requires knowing governance context
(multisig? timelock? renounced?) not visible in the code alone.

Next: Mythril symbolic execution scan, focused on `delegateBySig()`
and owner-privileged functions, running in background
(mythril-report.md).