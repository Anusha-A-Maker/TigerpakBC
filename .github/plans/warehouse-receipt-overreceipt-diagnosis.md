# Debug Session: Warehouse Receipt Over-Receipt Quantity Error

**Date**: 2026-10-26
**Severity**: Medium
**Status**: Fix implemented; build verification pending

## Issue Summary

Changing the quantity to receive in a warehouse receipt raises the Business Central error that a field cannot be changed because the sales order line is associated with a purchase order.

## Symptoms

- Expected: Update the quantity to receive, with the linked sales order quantity reflecting the permitted over-receipt.
- Actual: The receipt update fails with the purchase-order association error.

## Reproduction Steps

1. Open a warehouse receipt for a purchase order linked to a sales order (especially a special-order line).
2. Change the quantity to receive so the over-receipt quantity is recalculated.
3. The `Purchase Line` `Over-Receipt Quantity` subscriber attempts to update the linked sales line and the operation errors.

**Reproducibility**: Reported during warehouse receipt quantity updates; exact environment and stack trace were not provided.

## Root Cause

`OnAfterValidateOverReceiptQty` runs from the `Purchase Line` validation and calls `UpdateLinkedSalesLine`. For a special-order line, `FindLinkedSalesLine` returns the associated sales order line. `ApplyDelta` then changes that protected line with `SalesLine.Validate(Quantity, NewQty)` and `SalesLine.Modify(true)`.

Business Central's sales-line association check raises this exact error when `Special Order Purch. Line No.` is nonzero. The error is therefore caused by this subscriber trying to change the sales order quantity during receipt validation, not by the warehouse receipt quantity field itself. `SuspendStatusCheck(true)` only addresses the released-order status check; it does not remove or bypass the purchase-order association constraint.

The base sales-line cleanup logic does not clear the special-order association just because the purchase order is received or invoiced. It clears the relationship as part of deleting a fully invoiced sales line. Therefore, automatically increasing this same sales line after the PO closes is not a viable lifecycle point for selling the excess: the link can still prevent the edit, and the association is not a general PO-close callback.

## Implemented Fix

The user confirmed that the existing sales line must be increased without unlinking it and approved a narrow override of the association check. The handler now marks the specific sales line, purchase line, and target quantity while applying the over-receipt delta. The `OnBeforeCheckAssocPurchOrder` subscriber skips the base check only for that in-progress quantity validation and only when the purchase line still references the same special-order sales line. Other edits remain subject to the base association check. Validation errors are propagated after the temporary override context is cleared.

Reopening the sales order still only addresses the released-order status check; it does not bypass the separate purchase-association check.

## Testing Strategy

- Reproduce with a special-order purchase line and confirm the receipt quantity update no longer attempts to validate a sales-line quantity.
- Verify normal special-order receipt posting and partial receipts.
- If sales demand is to be increased, test the supported post-receipt workflow, including remaining purchase-order quantity and shipped quantity.
- Compile against the project's target Business Central symbols and verify the `OnBeforeCheckAssocPurchOrder` publisher exists in that version.

## Next Steps

1. Compile against the project's target Business Central symbols.
2. Validate the receipt scenarios in a Business Central test environment.
