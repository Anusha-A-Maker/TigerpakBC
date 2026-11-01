namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Ledger;

tableextension 70135 "Lot No. Information TExt" extends "Lot No. Information"
{
    fields
    {
        field(70110; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = ToBeClassified;
            //  TableRelation = "Item Ledger Entry"."Expiration Date" where("Lot No." = field("Lot No."), "Item No." = field("Item No."));
        }

    }

}
