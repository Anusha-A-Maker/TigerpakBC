namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Transfer;

tableextension 70134 "Transfer Header TExt" extends "Transfer Header"
{
    fields
    {

        modify("Posting Date")
        {
            trigger OnAfterValidate()
            var
                TransferLine: Record "Transfer Line";
            begin
                TransferLine.SetRange("Document No.", Rec."No.");
                if TransferLine.FindSet() then begin
                    repeat
                        TransferLine."Posting Date" := Rec."Posting Date";
                        TransferLine.Modify();
                    until TransferLine.Next() = 0;
                end;
            end;
        }
    }
}
