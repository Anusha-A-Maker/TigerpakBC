namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Transfer;

pageextension 70165 "Transfer Order Subform Ext" extends "Transfer Order Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("Posting Date"; rec."Posting Date")
            {
                ApplicationArea = All;
                Caption = 'Posting Date';
                ToolTip = 'Posting Date';
                Editable = false;
                Enabled = true;
                Visible = true;
            }
        }
    }
}