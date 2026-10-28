namespace TigerpakBC.TigerpakBC;

using Microsoft.Sales.Receivables;

page 70171 "Customer Ledger Apply API"
{
    PageType = API;
    APIPublisher = 'tigerpak';
    APIGroup = 'cashReceipts';
    APIVersion = 'v1.0';
    EntityName = 'customerLedgerApplication';
    EntitySetName = 'customerLedgerApplications';
    EntityCaption = 'Customer Ledger Application';
    EntitySetCaption = 'Customer Ledger Applications';
    SourceTable = "Cust. Ledger Entry";
    SourceTableView = where(Open = const(true), Positive = const(true), "Document Type" = const(Invoice));
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
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
                field(entryNumber; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry Number';
                    Editable = false;
                }
                field(customerNumber; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Number';
                    Editable = false;
                }
                field(documentNumber; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document Number';
                    Editable = false;
                }
                field(postingDate; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                    Editable = false;
                }
                field(dueDate; Rec."Due Date")
                {
                    ApplicationArea = All;
                    Caption = 'Due Date';
                    Editable = false;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Caption = 'Currency Code';
                    Editable = false;
                }
                field(remainingAmount; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Amount';
                    Editable = false;
                }
                field(appliesToId; Rec."Applies-to ID")
                {
                    ApplicationArea = All;
                    Caption = 'Applies-to ID';
                    Editable = false;
                }
                field(amountToApply; Rec."Amount to Apply")
                {
                    ApplicationArea = All;
                    Caption = 'Amount to Apply';
                    Editable = false;
                }
            }
        }
    }

    [ServiceEnabled]
    procedure SetPaymentApplication(var ActionContext: WebServiceActionContext; JournalLineSystemId: Guid; AmountToApply: Decimal)
    var
        CashReceiptApplication: Codeunit "Cash Receipt Application";
    begin
        CashReceiptApplication.SetPaymentApplication(Rec."Entry No.", JournalLineSystemId, AmountToApply);
        Rec.Get(Rec."Entry No.");
        Rec.CalcFields("Remaining Amount");

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"Customer Ledger Apply API");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    procedure ClearPaymentApplication(var ActionContext: WebServiceActionContext; JournalLineSystemId: Guid)
    var
        CashReceiptApplication: Codeunit "Cash Receipt Application";
    begin
        CashReceiptApplication.ClearPaymentApplication(Rec."Entry No.", JournalLineSystemId);
        Rec.Get(Rec."Entry No.");
        Rec.CalcFields("Remaining Amount");

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"Customer Ledger Apply API");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields("Remaining Amount");
    end;
}
