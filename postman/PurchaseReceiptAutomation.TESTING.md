# Purchase Receipt Automation — Sandbox Test Guide

## Scope

The current implementation exposes one OData V4 unbound action:

`POST /ODataV4/PurchaseRecieptAPI_GetReceiptLines?company=<company name>`

The action parameters are case-sensitive in the JSON body and must match OData metadata: `invoiceNo` and `receiptNo`.

The operation accepts an open purchase invoice number and a posted receipt number. It validates the invoice is open, the receipt exists, the vendor matches, the receipt has uninvoiced quantity, and the same receipt is not already linked to the invoice. It then uses standard codeunit 74, **Purch.-Get Receipt**, to create the invoice lines.

The response's OData `value` property contains JSON text with:

- `invoiceNo`
- `receiptNo`
- `linesCreated`
- `amount`
- `amountIncludingVAT`

This action does not post, release, or approve purchase documents. Item-charge assignment and Continia approval are not included in this required-action implementation.

## Prerequisites

1. Build the `Dev` branch extension and publish it to the **Sandbox** using the team's normal release process. This work does not publish to any BC environment.
2. In Business Central, open **Web Services** and publish:
   - Object Type: `Codeunit`
   - Object ID: `70174`
   - Service Name: `PurchaseRecieptAPI`
   - Published: enabled
3. Configure the S2S application for the Sandbox and assign approved least-privilege rights to execute codeunit 70174 and the required purchase operations. Do not use `SUPER` as a workaround. A dedicated extension permission set has not been generated because its permission scope is awaiting approval.
4. Prepare test data in the Sandbox:
   - An **Open** purchase invoice for a vendor.
   - A posted purchase receipt for that same vendor with positive **Qty. Rcd. Not Invoiced**.
   - A second eligible posted receipt for the same vendor, if testing multiple receipts.
   - A posted receipt for a different vendor and an open invoice for that other vendor, if testing the vendor-mismatch rejection.
5. Import [PurchaseReceiptAutomation.postman_collection.json](./PurchaseReceiptAutomation.postman_collection.json) into Postman.

## Configure Postman

Set the collection variables:

| Variable | Value |
|---|---|
| `bcBaseUrl` | `https://api.businesscentral.dynamics.com/v2.0/<tenant-id>/<sandbox-environment>` |
| `tenantId` | Your Entra tenant ID |
| `environmentName` | The Sandbox environment name |
| `companyName` | Exact BC company name in the Sandbox |
| `serviceName` | `PurchaseRecieptAPI` |
| `accessToken` | OAuth 2.0 access token for the S2S application |
| `invoiceNo` | Open purchase invoice number |
| `receiptNo` | Posted receipt number for the invoice vendor |
| `secondReceiptNo` | A different eligible receipt for the same vendor |
| `mismatchInvoiceNo` | Open invoice for a different vendor than `receiptNo` |

For OAuth client credentials, request a token for the Business Central API scope:

`https://api.businesscentral.dynamics.com/.default`

Use the token in the `accessToken` variable. Keep client secrets out of the collection and source control.

## Test sequence

### 1. Add the first receipt

Run **Get Receipt Lines**.

Expected:

- HTTP `200`.
- The response `value` contains valid JSON text.
- `linesCreated` is greater than zero.
- `amount` and `amountIncludingVAT` are returned.

In BC, open the invoice and verify the lines match the selected posted receipt, including receipt references and the standard dimensions, comments, and charge-line behavior supplied by codeunit 74. Confirm the returned totals match the invoice. Confirm the invoice remains unposted and open.

### 2. Add another receipt to that invoice

Set `secondReceiptNo` to a different posted receipt for the same vendor and run **Add a different receipt to the same invoice**.

Expected: HTTP `200`, one or more additional lines, and updated totals. Verify that the second receipt's lines were added while the first receipt's lines remain.

### 3. Reject a duplicate receipt

After step 1 succeeds, run **Reject the same receipt twice** with the same `invoiceNo` and `receiptNo`.

Expected: an OData error response containing `already been added`. Verify that no additional invoice lines were created.

### 4. Reject a vendor mismatch

Set `mismatchInvoiceNo` to an open invoice for a different vendor than `receiptNo`, then run **Reject a vendor mismatch**.

Expected: an OData error response containing `belongs to vendor`. Verify that no lines were added to that invoice.

### 5. Additional validation cases

Repeat with the following inputs and confirm each request fails without changing invoice lines:

- Blank `invoiceNo`.
- Blank `receiptNo`.
- An invoice number that does not exist.
- A non-open invoice.
- A receipt number that does not exist.
- A receipt with no remaining quantity to invoice.

## Troubleshooting

- **Action not found:** Confirm the extension is installed in the Sandbox and the codeunit is published under the exact service name above. The OData operation name is case-sensitive in the request URL.
- **401/403:** Check the token tenant/environment/audience, S2S application registration, Web Services publication, and assigned permissions.
- **Company not found:** Use the exact company name in the `company` query parameter.
- **No eligible quantity:** Choose a posted receipt with positive `Qty. Rcd. Not Invoiced`.
- **Invoice unchanged after an error:** This is expected; correct the failing input and retry.
