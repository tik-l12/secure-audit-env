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