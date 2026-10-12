namespace TigerpakBC.TigerpakBC;

using Microsoft.Sales.Customer;

pageextension 70166 "Customer List Ext" extends "Customer List"
{

    layout
    {
        addafter("Location Code")
        {
            field(ABN; Rec.ABN)
            {
                ApplicationArea = All;
                Caption = 'ABN Number';
                Editable = false;
            }
        }
    }
}
