namespace TigerpakBC.TigerpakBC;
using Microsoft.Inventory.Ledger;

tableextension 70131 "WTPL Label List TExt" extends "WTPL Label List"
{
    fields
    {
        field(70100; "Lot No.";Code[20])
        {
            Caption = 'Lot No.';
            DataClassification = ToBeClassified;
           // tableRelation = "Item Ledger Entry"."Lot No." where ("Item Ledger Entry"."Item No." = field("WT Item No."));
            trigger onlookup()
            var
                ILE : Record "Item Ledger Entry";
                begin
                    ILE.setrange("Item No.", "WT Item No.");
                    if ILE.FindFirst() then
                        if PAGE.Runmodal(PAGE::"Item Ledger Entries", ILE) = ACTION::LookupOK then
                            "Lot No." := ILE."Lot No."; 
                            "Expiry Date" := ILE."Expiration Date";
                end;
           

        }

        field(700101; "Expiry Date";Date)
        {
            Caption = 'Expiry Date';
            DataClassification = ToBeClassified;
        }
    }

var
ILE : Record "Item Ledger Entry";
 
}
