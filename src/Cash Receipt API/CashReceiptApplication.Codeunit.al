namespace TigerpakBC.TigerpakBC;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;

codeunit 70172 "Cash Receipt Application"
{
    Permissions =
        tabledata "Cust. Ledger Entry" = RM,
        tabledata "Gen. Journal Line" = M;

    /// <summary>
    /// Applies a requested amount from a draft cash receipt journal line to an open customer invoice.
    /// </summary>
    /// <param name="CustomerLedgerEntryNo">The customer ledger entry number of the open invoice.</param>
    /// <param name="JournalLineSystemId">The system ID of the draft cash receipt journal line.</param>
    /// <param name="AmountToApply">The positive application amount in the invoice currency.</param>
    procedure SetPaymentApplication(CustomerLedgerEntryNo: Integer; JournalLineSystemId: Guid; AmountToApply: Decimal)
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        OtherAppliedEntries: Record "Cust. Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        ApplyingCustomerLedgerEntry: Record "Cust. Ledger Entry";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        OtherAllocationsAmount: Decimal;
        AppliesToID: Code[50];
        InvalidInvoiceErr: Label 'Customer ledger entry %1 is not an open invoice for the customer on journal line %2.', Comment = '%1 = customer ledger entry number; %2 = journal line number.';
        InvalidAmountErr: Label 'Amount to Apply must be greater than zero and cannot exceed the invoice remaining amount.', Comment = 'Validation message for a partial payment allocation.';
        CurrencyMismatchErr: Label 'The invoice and payment journal line must use the same currency.', Comment = 'Cross-currency cash receipt applications are not supported by this API.';
        ConflictingAppliesToErr: Label 'The invoice is already assigned to a different payment. Clear its existing application before assigning it again.', Comment = 'Validation message for conflicting customer ledger application IDs.';
        AllocationExceedsPaymentErr: Label 'The invoice allocations would exceed the journal line amount.', Comment = 'Validation message when requested allocations exceed the payment amount.';
    begin
        GenJournalLine.LockTable();
        CustomerLedgerEntry.LockTable();
        ValidatePaymentJournalLine(GenJournalLine, JournalLineSystemId);

        if not CustomerLedgerEntry.Get(CustomerLedgerEntryNo) then
            Error(InvalidInvoiceErr, CustomerLedgerEntryNo, GenJournalLine."Line No.");

        CustomerLedgerEntry.TestField(Open, true);
        CustomerLedgerEntry.TestField(Positive, true);
        CustomerLedgerEntry.TestField("Document Type", CustomerLedgerEntry."Document Type"::Invoice);

        if CustomerLedgerEntry."Customer No." <> GenJournalLine."Account No." then
            Error(InvalidInvoiceErr, CustomerLedgerEntryNo, GenJournalLine."Line No.");
        if CustomerLedgerEntry."Currency Code" <> GenJournalLine."Currency Code" then
            Error(CurrencyMismatchErr);
        if AmountToApply <= 0 then
            Error(InvalidAmountErr);

        CustomerLedgerEntry.CalcFields("Remaining Amount");
        if AmountToApply > Abs(CustomerLedgerEntry."Remaining Amount") then
            Error(InvalidAmountErr);

        AppliesToID := GenJournalLine."Document No.";
        if CustomerLedgerEntry."Applies-to ID" <> '' then
            if CustomerLedgerEntry."Applies-to ID" <> AppliesToID then
                Error(ConflictingAppliesToErr);

        ValidateUniquePaymentDocumentNo(GenJournalLine);
        ValidateTotalAllocations(OtherAppliedEntries, GenJournalLine, CustomerLedgerEntryNo, OtherAllocationsAmount);
        if (OtherAllocationsAmount + AmountToApply) > Abs(GenJournalLine.Amount) then
            Error(AllocationExceedsPaymentErr);

        if GenJournalLine."Applies-to ID" = '' then begin
            GenJournalLine.Validate("Applies-to ID", AppliesToID);
            GenJournalLine.Modify(true);
        end else
            if GenJournalLine."Applies-to ID" <> AppliesToID then
                Error(ConflictingAppliesToErr);

        if CustomerLedgerEntry."Applies-to ID" = '' then begin
            CustomerLedgerEntry.Reset();
            CustomerLedgerEntry.SetRange("Entry No.", CustomerLedgerEntryNo);
            CustEntrySetApplID.SetApplId(CustomerLedgerEntry, ApplyingCustomerLedgerEntry, AppliesToID);
        end;

        CustomerLedgerEntry.Get(CustomerLedgerEntryNo);
        CustomerLedgerEntry.Validate("Amount to Apply", AmountToApply);
        Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustomerLedgerEntry);
    end;

    /// <summary>
    /// Removes an invoice allocation from its draft cash receipt journal line.
    /// </summary>
    /// <param name="CustomerLedgerEntryNo">The customer ledger entry number of the invoice to unapply.</param>
    /// <param name="JournalLineSystemId">The system ID of the draft cash receipt journal line.</param>
    procedure ClearPaymentApplication(CustomerLedgerEntryNo: Integer; JournalLineSystemId: Guid)
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        OtherAppliedEntries: Record "Cust. Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        AppliesToID: Code[50];
        ApplicationNotFoundErr: Label 'Invoice %1 is not marked for payment line %2.', Comment = '%1 = customer ledger entry number; %2 = journal line number.';
        InvalidInvoiceErr: Label 'Customer ledger entry %1 is not an open invoice for journal line %2.', Comment = '%1 = customer ledger entry number; %2 = journal line number.';
    begin
        GenJournalLine.LockTable();
        CustomerLedgerEntry.LockTable();
        ValidatePaymentJournalLine(GenJournalLine, JournalLineSystemId);
        if not CustomerLedgerEntry.Get(CustomerLedgerEntryNo) then
            Error(InvalidInvoiceErr, CustomerLedgerEntryNo, GenJournalLine."Line No.");

        CustomerLedgerEntry.TestField(Open, true);
        CustomerLedgerEntry.TestField(Positive, true);
        CustomerLedgerEntry.TestField("Document Type", CustomerLedgerEntry."Document Type"::Invoice);

        AppliesToID := GenJournalLine."Document No.";
        if CustomerLedgerEntry."Applies-to ID" <> AppliesToID then
            Error(ApplicationNotFoundErr, CustomerLedgerEntryNo, GenJournalLine."Line No.");

        CustomerLedgerEntry.Reset();
        CustomerLedgerEntry.SetRange("Entry No.", CustomerLedgerEntryNo);
        CustEntrySetApplID.RemoveApplId(CustomerLedgerEntry, AppliesToID);

        if GenJournalLine."Applies-to ID" = AppliesToID then begin
            OtherAppliedEntries.SetRange("Customer No.", GenJournalLine."Account No.");
            OtherAppliedEntries.SetRange(Open, true);
            OtherAppliedEntries.SetRange("Applies-to ID", AppliesToID);
            if OtherAppliedEntries.IsEmpty() then begin
                GenJournalLine.Validate("Applies-to ID", '');
                GenJournalLine.Modify(true);
            end;
        end;
    end;

    local procedure ValidatePaymentJournalLine(var GenJournalLine: Record "Gen. Journal Line"; JournalLineSystemId: Guid)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalLineNotFoundErr: Label 'Cash receipt journal line %1 was not found.', Comment = '%1 = journal line system ID.';
        InvalidPaymentErr: Label 'Journal line %1 is not an editable customer payment in a Cash Receipts journal batch.', Comment = '%1 = journal line number.';
    begin
        if not GenJournalLine.GetBySystemId(JournalLineSystemId) then
            Error(JournalLineNotFoundErr, JournalLineSystemId);

        if (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Payment) or
           (GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Customer) or
           (GenJournalLine.Amount >= 0) or
           (GenJournalLine."Document No." = '')
        then
            Error(InvalidPaymentErr, GenJournalLine."Line No.");

        if not GenJournalTemplate.Get(GenJournalLine."Journal Template Name") then
            Error(InvalidPaymentErr, GenJournalLine."Line No.");
        if GenJournalTemplate.Type <> GenJournalTemplate.Type::"Cash Receipts" then
            Error(InvalidPaymentErr, GenJournalLine."Line No.");
        if not GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name") then
            Error(InvalidPaymentErr, GenJournalLine."Line No.");
    end;

    local procedure ValidateUniquePaymentDocumentNo(GenJournalLine: Record "Gen. Journal Line")
    var
        OtherJournalLine: Record "Gen. Journal Line";
        DuplicatePaymentErr: Label 'Document No. %1 is used by another customer payment for this customer. Use a unique payment document number.', Comment = '%1 = payment document number.';
    begin
        OtherJournalLine.LockTable();
        OtherJournalLine.SetRange("Document Type", OtherJournalLine."Document Type"::Payment);
        OtherJournalLine.SetRange("Account Type", OtherJournalLine."Account Type"::Customer);
        OtherJournalLine.SetRange("Account No.", GenJournalLine."Account No.");
        OtherJournalLine.SetRange("Document No.", GenJournalLine."Document No.");
        if OtherJournalLine.FindSet() then
            repeat
                if OtherJournalLine.SystemId <> GenJournalLine.SystemId then
                    Error(DuplicatePaymentErr, GenJournalLine."Document No.");
            until OtherJournalLine.Next() = 0;
    end;

    local procedure ValidateTotalAllocations(var OtherAppliedEntries: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; CustomerLedgerEntryNo: Integer; var OtherAllocationsAmount: Decimal)
    begin
        OtherAppliedEntries.SetRange("Customer No.", GenJournalLine."Account No.");
        OtherAppliedEntries.SetRange("Currency Code", GenJournalLine."Currency Code");
        OtherAppliedEntries.SetRange(Open, true);
        OtherAppliedEntries.SetRange(Positive, true);
        OtherAppliedEntries.SetRange("Applies-to ID", GenJournalLine."Document No.");
        OtherAppliedEntries.SetFilter("Entry No.", '<>%1', CustomerLedgerEntryNo);
        OtherAppliedEntries.CalcSums("Amount to Apply");
        OtherAllocationsAmount := Abs(OtherAppliedEntries."Amount to Apply");
    end;
}
