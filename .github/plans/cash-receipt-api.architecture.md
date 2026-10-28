# Cash Receipt Automation API

## Status

Implemented on the `Dev` branch only. `Main` was not changed. Compile/runtime validation is pending the matching BC 24.2 symbols and test environment.

## Goal

Allow an external application to create and maintain draft customer payment lines in a dedicated Cash Receipt Journal batch, assign explicit invoice application amounts, then leave review and posting to a Business Central user.

## API Contract

Publisher: `tigerpak`  
Group: `cashReceipts`  
Version: `v1.0`

### Draft cash receipt journal lines

Entity set: `cashReceiptJournalLines`

- `POST` creates a payment line in an existing journal batch whose template type is Cash Receipts.
- `PATCH` updates a draft line.
- `GET` reads draft journal lines for the user review workflow.
- Delete is disabled through this endpoint.
- Only customer payment lines are accepted; the integration cannot post.
- The client supplies `journalTemplateName`, `journalBatchName`, `lineNumber`, `documentType`, `documentNumber`, `postingDate`, `accountType`, `accountNumber`, `amount`, and any required balancing account fields.
- Each payment line must have a unique document number for that customer across the company. That document number is the payment's Applies-to ID.

### Example request flow

Base URL:

`/api/tigerpak/cashReceipts/v1.0/companies({companyId})`

1. `POST /cashReceiptJournalLines` with the Cash Receipts template/batch, a unique line number and payment document number, customer, posting date, payment amount, and balancing account details. For example:

   ```json
   {
     "journalTemplateName": "CASHREC",
     "journalBatchName": "EXTERNAL",
     "lineNumber": 10000,
     "documentType": "Payment",
     "documentNumber": "PAY-10001",
     "postingDate": "2026-10-28",
     "accountType": "Customer",
     "accountNumber": "C10000",
     "currencyCode": "",
     "amount": -125.50,
     "balancingAccountType": "Bank Account",
     "balancingAccountNumber": "BANK"
   }
   ```

   Save the returned `id` (`SystemId`).
2. `GET /customerLedgerApplications?$filter=customerNumber eq '{customerNo}'` to find open invoices. Save the selected invoice `id` (`SystemId`).
3. For each invoice allocation, call `POST /customerLedgerApplications({invoiceSystemId})/Microsoft.NAV.SetPaymentApplication` with:

   ```json
   {
     "journalLineSystemId": "00000000-0000-0000-0000-000000000000",
     "amountToApply": 125.50
   }
   ```

4. Read the draft lines from `cashReceiptJournalLines` and review them in the standard Cash Receipt Journal.
5. To correct an allocation before posting, call `POST /customerLedgerApplications({invoiceSystemId})/Microsoft.NAV.ClearPaymentApplication` with the same `journalLineSystemId`, then set the corrected amount.

The application amount is sent as a JSON number and parsed by the Business Central API action parameter binding.

### Open customer invoice applications

Entity set: `customerLedgerApplications`

- `GET` reads open positive customer invoice entries and their remaining balances.
- `POST .../Microsoft.NAV.SetPaymentApplication` takes `journalLineSystemId` and `amountToApply`.
- The bound action verifies the draft cash-receipt line, customer, currency, document number, open invoice, and total allocations.
- It uses the standard customer Applies-to ID codeunit and Customer Entry-Edit codeunit to mark the invoice and persist the requested amount.
- A second action, `ClearPaymentApplication`, removes an incorrect invoice allocation and clears the journal line's Applies-to ID only when no other open invoice allocations remain for that payment.
- The API does not directly patch ledger application fields and does not post journal lines.

## Allocation Rules

- One payment journal line may apply to multiple open invoices.
- The external application supplies an explicit amount in the invoice currency for each invoice allocation.
- Payment and invoice currency must match. Cross-currency application is excluded from this first API version.
- The total of invoice allocations cannot exceed the payment journal line amount.
- A customer ledger entry already marked for another payment cannot be reassigned until the prior allocation is cleared.
- Journal line document numbers must be unique for that customer across the company to prevent separate payments sharing an Applies-to ID.

## Security

The dedicated integration permission set grants:

| Object / data | Permission | Reason |
|---|---:|---|
| Cash Receipt Journal API page | X | Create/read/update draft journal lines |
| Customer Ledger Apply API page | X | Read invoice entries and invoke application actions |
| Cash Receipt Application codeunit | X | Run guarded application workflow |
| Gen. Journal Line table data | RIM | Create and maintain draft lines; no delete |
| Gen. Journal Template / Batch table data | R | Confirm the target batch is a Cash Receipts batch |
| Customer Ledger Entry table data | R | Read invoices; application codeunit performs guarded writes |

The integration receives no permission to delete customer ledger entries or post journal lines.

## Review and Posting

Users review the resulting lines in the standard Cash Receipt Journal using the dedicated batch. Posting remains a user action in Business Central.

## Validation

Compile against the extension's declared BC 24.2 symbols and test: creation/edit of draft lines; full and partial allocations; multiple invoices per payment; amount over-allocation; currency mismatch; duplicate document number; conflicting Applies-to ID; clear/reapply behavior; review and posting from the standard journal. The local workspace has BC 28.x symbols rather than BC 24.2, so the extension has not yet been compiled or run against its target.
