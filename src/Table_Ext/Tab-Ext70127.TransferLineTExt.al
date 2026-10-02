namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Transfer;

tableextension 70127 "Transfer Line TExt" extends "Transfer Line"
{
    fields
    {
        field(70100; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                TransferHeader: Record "Transfer Header";
            begin

                if TransferHeader.Get("Document No.") then begin
                    Rec."Posting Date" := TransferHeader."Posting Date";
                    Rec.Modify();
                end;

            end;
        }
    }


}
