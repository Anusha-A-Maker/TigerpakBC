namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Tracking;

tableextension 70132 "Lot No. Information TExt" extends "Lot No. Information"
{
    fields
    {
        field(70110; "Expiration Date";Date)
        {
            Caption = 'Expiration Date';
            DataClassification = ToBeClassified;
                TableRelation = "Item Ledger Entry"."Expiration Date" where("Lot No." = field("Lot No."), "Item No." = field("Item No."));
        }
        
    }

    trigger oninsert()
    var
        ILE : Record "Item Ledger Entry";
        begin
            ILE.setrange("Item No.", "Item No.");
            ILE.setrange("Lot No.", "Lot No.");
            if ILE.FindFirst() then
                "Expiration Date" := ILE."Expiration Date";
        end;
    
}
