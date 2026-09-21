namespace TigerpakBC.TigerpakBC;
using Microsoft.Inventory.Transfer;
using Microsoft.Inventory.Location;

page 70117 "GIT Availability"
{
    ApplicationArea = All;
    Caption = 'GIT Availability';
    PageType = List;
    SourceTable = "GIT Availability";

    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = Lists;



    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(DocumentNo; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies the document number of the transfer order.';
                }
                field(Location; Rec.Location)
                {
                    ApplicationArea = All;
                    Caption = 'Location';
                    ToolTip = 'Specifies the location the goods are being sent from.';
                }
                field(Item; Rec.Item)
                {
                    ApplicationArea = All;
                    Caption = 'Item';
                    ToolTip = 'Specifies the item being sent.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the item being sent.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    Editable = false;
                    ToolTip = 'Specifies the quantity of the item that has been shipped but not received.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Caption = 'Unit Cost';
                    Editable = false;
                    ToolTip = 'Specifies the cost per unit of the item being sent.';
                }
                field("Receiving Location"; Rec."Receiving Location")
                {
                    ApplicationArea = All;
                    Caption = 'Receiving Location';
                    ToolTip = 'Specifies the location receiving the goods.';
                }
            }
        }
    }

    local procedure LoadGoodsInTransit()
    var
        TransferLines: Record "Transfer Line";
        EntryNo: Integer;
        SKU: Record "Stockkeeping Unit";
    begin
        Rec.DeleteAll();
        if TransferLines.FindSet() then
            repeat
                if TransferLines."Qty. Shipped (Base)" > TransferLines."Qty. Received (Base)" then begin
                    EntryNo += 1;
                    Rec.Init();
                    Rec."Entry No." := EntryNo;
                    Rec."Document No." := TransferLines."Document No.";
                    Rec.Location := TransferLines."Transfer-from Code";
                    Rec.Item := TransferLines."Item No.";
                    Rec.Description := TransferLines.Description;
                    Rec.Quantity := TransferLines."Qty. Shipped (Base)" - TransferLines."Qty. Received (Base)";
                    // Rec."Unit Cost" := TransferLines."Unit Cost";
                    Rec."Receiving Location" := TransferLines."Transfer-to Code";
                    SKU.SetRange("Item No.", Rec."Item");
                    SKU.SetRange("Location Code", Rec.Location);
                    if SKU.FindFirst() then begin
                        Rec."Unit Cost" := SKU."Unit Cost";
                    end;
                    Rec.Insert();
                end;
            until TransferLines.Next() = 0;
    end;

    trigger OnOpenPage()
    begin
        LoadGoodsInTransit();
    end;
}
