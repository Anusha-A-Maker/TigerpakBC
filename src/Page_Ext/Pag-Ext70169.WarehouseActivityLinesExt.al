namespace TigerpakBC.TigerpakBC;

using Microsoft.Warehouse.Activity;

pageextension 70169 "Warehouse Activity Lines Ext" extends "Warehouse Activity Lines"
{
    // actions
    // {

    //     addafter(ShowDocument)   //To Delete Orphaned Lines in warehouse activity lines to clear Pick quantity in Bin contents - Justin
    //     {
    //         action("Delete Orphaned Lines")
    //         {
    //             ApplicationArea = All;
    //             Caption = 'Delete Orphaned Lines';
    //             Image = DeleteLines;
    //             trigger OnAction()
    //             begin
    //                 if rec."No." = 'PI363423' then
    //                     rec.Delete();
    //             end;

    //         }
    //     }
    // }
}
