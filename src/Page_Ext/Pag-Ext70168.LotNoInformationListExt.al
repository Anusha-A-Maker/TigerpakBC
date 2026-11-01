namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Tracking;

pageextension 70168 "Lot No. Information List Ext" extends "Lot No. Information List"
{
    layout
    {
        addafter(Description)
        {
            field("Expiration Date"; Rec."Expiration Date")
            {
                ApplicationArea = All;
                Caption = 'Expiration Date';
            }
        }
    }
}
