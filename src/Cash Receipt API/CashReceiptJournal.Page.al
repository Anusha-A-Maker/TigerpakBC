namespace TigerpakBC.TigerpakBC;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;

page 70170 "Cash Receipt Journal API"
{
    PageType = API;
    APIPublisher = 'tigerpak';
    APIGroup = 'cashReceipts';
    APIVersion = 'v1.0';
    EntityName = 'cashReceiptJournalLine';
    EntitySetName = 'cashReceiptJournalLines';
    EntityCaption = 'Cash Receipt Journal Line';
    EntitySetCaption = 'Cash Receipt Journal Lines';
    SourceTable = "Gen. Journal Line";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Caption = 'Id';
                    Editable = false;
                }
                field(journalTemplateName; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    Caption = 'Journal Template Name';
                }
                field(journalBatchName; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Caption = 'Journal Batch Name';
                }
                field(lineNumber; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'Line Number';
                }
                field(documentType; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                }
                field(documentNumber; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document Number';
                }
                field(postingDate; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                }
                field(accountType; Rec."Account Type")
                {
                    ApplicationArea = All;
                    Caption = 'Account Type';
                }
                field(accountNumber; Rec."Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Account Number';
                }
                field(description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Caption = 'Currency Code';
                }
                field(amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                }
                field(balancingAccountType; Rec."Bal. Account Type")
                {
                    ApplicationArea = All;
                    Caption = 'Balancing Account Type';
                }
                field(balancingAccountNumber; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Balancing Account Number';
                }
                field(appliesToId; Rec."Applies-to ID")
                {
                    ApplicationArea = All;
                    Caption = 'Applies-to ID';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        ValidateCashReceiptJournalLine();
        ValidateUniquePaymentDocumentNo();
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ValidateCashReceiptJournalLine();
        ValidateUniquePaymentDocumentNo();
        ValidateExistingApplications();
        exit(true);
    end;

    local procedure ValidateCashReceiptJournalLine()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        PaymentAmountErr: Label 'Customer payment journal line amount must be negative.', Comment = 'Cash receipt customer payments must have a negative journal line amount.';
    begin
        Rec.TestField("Journal Template Name");
        Rec.TestField("Journal Batch Name");
        Rec.TestField("Line No.");
        Rec.TestField("Document Type", Rec."Document Type"::Payment);
        Rec.TestField("Document No.");
        Rec.TestField("Posting Date");
        Rec.TestField("Account Type", Rec."Account Type"::Customer);
        Rec.TestField("Account No.");
        Rec.TestField(Amount);
        if Rec.Amount >= 0 then
            Error(PaymentAmountErr);

        GenJournalTemplate.Get(Rec."Journal Template Name");
        GenJournalTemplate.TestField(Type, GenJournalTemplate.Type::"Cash Receipts");

        GenJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
    end;

    local procedure ValidateUniquePaymentDocumentNo()
    var
        OtherJournalLine: Record "Gen. Journal Line";
        DuplicatePaymentErr: Label 'Document No. %1 is already used by another customer payment for this customer.', Comment = '%1 = payment document number.';
    begin
        OtherJournalLine.LockTable();
        OtherJournalLine.SetRange("Document Type", OtherJournalLine."Document Type"::Payment);
        OtherJournalLine.SetRange("Account Type", OtherJournalLine."Account Type"::Customer);
        OtherJournalLine.SetRange("Account No.", Rec."Account No.");
        OtherJournalLine.SetRange("Document No.", Rec."Document No.");
        if OtherJournalLine.FindSet() then
            repeat
                if OtherJournalLine.SystemId <> Rec.SystemId then
                    Error(DuplicatePaymentErr, Rec."Document No.");
            until OtherJournalLine.Next() = 0;
    end;

    local procedure ValidateExistingApplications()
    var
        AppliedCustomerLedgerEntry: Record "Cust. Ledger Entry";
        AppliedAmountErr: Label 'The journal line amount cannot be less than the amounts already allocated to its invoices.', Comment = 'Validation message when reducing a payment below its applied amount.';
        PaymentDetailsErr: Label 'Do not change the journal batch, document number, document type, customer, or currency after invoice applications have been assigned.', Comment = 'Validation message when changing payment identity fields after applying invoices.';
    begin
        if xRec."Applies-to ID" = '' then
            exit;

        if (xRec."Journal Template Name" <> Rec."Journal Template Name") or
           (xRec."Journal Batch Name" <> Rec."Journal Batch Name") or
           (xRec."Document Type" <> Rec."Document Type") or
           (xRec."Document No." <> Rec."Document No.") or
           (xRec."Account Type" <> Rec."Account Type") or
           (xRec."Account No." <> Rec."Account No.") or
           (xRec."Currency Code" <> Rec."Currency Code")
        then
            Error(PaymentDetailsErr);

        AppliedCustomerLedgerEntry.SetRange("Customer No.", Rec."Account No.");
        AppliedCustomerLedgerEntry.SetRange("Currency Code", Rec."Currency Code");
        AppliedCustomerLedgerEntry.SetRange(Open, true);
        AppliedCustomerLedgerEntry.SetRange(Positive, true);
        AppliedCustomerLedgerEntry.SetRange("Applies-to ID", Rec."Applies-to ID");
        AppliedCustomerLedgerEntry.CalcSums("Amount to Apply");
        if Abs(Rec.Amount) < Abs(AppliedCustomerLedgerEntry."Amount to Apply") then
            Error(AppliedAmountErr);
    end;
}
