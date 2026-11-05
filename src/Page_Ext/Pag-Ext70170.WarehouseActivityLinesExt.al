namespace TigerpakBC.TigerpakBC;

using Microsoft.Warehouse.Activity;

pageextension 70170 "Warehouse Activity Lines Ext" extends "Warehouse Activity Lines"
{
    actions
    {

        addafter(ShowDocument)
        {
            action("Delete Orphaned Lines")
            {
                ApplicationArea = All;
                Caption = 'Delete Orphaned Lines';
                Image = DeleteLines;
                trigger OnAction()
                begin
                    if rec."No." = 'PI027683' then
                        rec.Delete();
                end;

            }
        }
    }
}
