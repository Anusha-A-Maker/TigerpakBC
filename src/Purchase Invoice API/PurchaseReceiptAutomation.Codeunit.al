namespace TigerpakBC.TigerpakBC;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;

codeunit 70174 "Purchase Receipt API"
{
    /// <summary>
    /// Adds eligible posted receipt lines to an open purchase invoice using standard Business Central logic.
    /// </summary>
    /// <param name="InvoiceNo">The number of the open purchase invoice to update.</param>
    /// <param name="ReceiptNo">The posted purchase receipt number to add. A receipt already added to the invoice is rejected.</param>
    /// <returns>JSON text containing the number of created lines and the updated invoice amounts.</returns>
    procedure GetReceiptLines(InvoiceNo: Code[20]; ReceiptNo: Code[20]): Text
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchGetReceipt: Codeunit "Purch.-Get Receipt";
        Response: JsonObject;
        ResponseText: Text;
        LinesBefore: Integer;
        LinesAfter: Integer;
        LinesCreated: Integer;
        HasQuantityToInvoice: Boolean;
        InvoiceNoRequiredErr: Label 'Invoice No. is required.', Comment = 'Validation error when the invoice number is missing from the API request.';
        ReceiptNoRequiredErr: Label 'Receipt No. is required.', Comment = 'Validation error when the posted receipt number is missing from the API request.';
        InvoiceNotFoundErr: Label 'Purchase invoice %1 was not found.', Comment = '%1 = purchase invoice number.';
        InvoiceNotOpenErr: Label 'Purchase invoice %1 must be open before receipt lines can be added.', Comment = '%1 = purchase invoice number.';
        ReceiptNotFoundErr: Label 'Posted purchase receipt %1 was not found.', Comment = '%1 = posted purchase receipt number.';
        VendorMismatchErr: Label 'Receipt %1 belongs to vendor %2, but invoice %3 belongs to vendor %4.', Comment = '%1 = receipt number; %2 = receipt vendor number; %3 = invoice number; %4 = invoice vendor number.';
        ReceiptAlreadyAddedErr: Label 'Receipt %1 has already been added to invoice %2.', Comment = '%1 = posted receipt number; %2 = purchase invoice number.';
        ReceiptHasNoLinesErr: Label 'Receipt %1 has no lines.', Comment = '%1 = posted purchase receipt number.';
        ReceiptHasNoQuantityErr: Label 'Receipt %1 has no quantity available to invoice.', Comment = '%1 = posted purchase receipt number.';
        NoLinesCreatedErr: Label 'No invoice lines were created from receipt %1.', Comment = '%1 = posted purchase receipt number.';
    begin
        if InvoiceNo = '' then
            Error(InvoiceNoRequiredErr);
        if ReceiptNo = '' then
            Error(ReceiptNoRequiredErr);

        PurchaseHeader.LockTable();
        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, InvoiceNo) then
            Error(InvoiceNotFoundErr, InvoiceNo);
        if PurchaseHeader.Status <> PurchaseHeader.Status::Open then
            Error(InvoiceNotOpenErr, InvoiceNo);

        if not PurchRcptHeader.Get(ReceiptNo) then
            Error(ReceiptNotFoundErr, ReceiptNo);
        if PurchRcptHeader."Buy-from Vendor No." <> PurchaseHeader."Buy-from Vendor No." then
            Error(
                VendorMismatchErr,
                ReceiptNo,
                PurchRcptHeader."Buy-from Vendor No.",
                InvoiceNo,
                PurchaseHeader."Buy-from Vendor No.");

        PurchaseLine.LockTable();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Invoice);
        PurchaseLine.SetRange("Document No.", InvoiceNo);
        PurchaseLine.SetRange("Receipt No.", ReceiptNo);
        if not PurchaseLine.IsEmpty() then
            Error(ReceiptAlreadyAddedErr, ReceiptNo, InvoiceNo);

        PurchRcptLine.SetRange("Document No.", ReceiptNo);
        if not PurchRcptLine.FindSet() then
            Error(ReceiptHasNoLinesErr, ReceiptNo);

        repeat
            if PurchRcptLine."Buy-from Vendor No." <> PurchaseHeader."Buy-from Vendor No." then
                Error(
                    VendorMismatchErr,
                    ReceiptNo,
                    PurchRcptLine."Buy-from Vendor No.",
                    InvoiceNo,
                    PurchaseHeader."Buy-from Vendor No.");
            if PurchRcptLine."Qty. Rcd. Not Invoiced" > 0 then
                HasQuantityToInvoice := true;
        until PurchRcptLine.Next() = 0;

        if not HasQuantityToInvoice then
            Error(ReceiptHasNoQuantityErr, ReceiptNo);

        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Invoice);
        PurchaseLine.SetRange("Document No.", InvoiceNo);
        LinesBefore := PurchaseLine.Count();

        PurchRcptLine.Reset();
        PurchRcptLine.SetRange("Document No.", ReceiptNo);
        PurchGetReceipt.SetPurchHeader(PurchaseHeader);
        if PurchRcptLine.FindSet() then
            repeat
                PurchGetReceipt.CreateInvLines(PurchRcptLine);
            until PurchRcptLine.Next() = 0;

        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Invoice);
        PurchaseLine.SetRange("Document No.", InvoiceNo);
        LinesAfter := PurchaseLine.Count();
        LinesCreated := LinesAfter - LinesBefore;
        if LinesCreated <= 0 then
            Error(NoLinesCreatedErr, ReceiptNo);

        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, InvoiceNo);
        PurchaseHeader.CalcFields(Amount, "Amount Including VAT");

        Response.Add('invoiceNo', InvoiceNo);
        Response.Add('receiptNo', ReceiptNo);
        Response.Add('linesCreated', LinesCreated);
        Response.Add('amount', PurchaseHeader.Amount);
        Response.Add('amountIncludingVAT', PurchaseHeader."Amount Including VAT");
        Response.WriteTo(ResponseText);
        exit(ResponseText);
    end;
}
