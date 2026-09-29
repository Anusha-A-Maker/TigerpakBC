namespace ALProject.ALProject;

using Microsoft.Inventory.Location;
using Microsoft.Sales.History;
using Microsoft.Inventory.Item;

pageextension 70124 "Stockkeeping Unit List Ext" extends "Stockkeeping Unit List"
{
    layout
    {
        addafter("Unit Cost")
        {
            field("TP Unit Cost_New"; rec."TP Unit Cost_New")
            {
                ApplicationArea = All;
                Caption = 'TP Unit Cost_New';
                ToolTip = 'TP Unit Cost_New';
                Editable = false;
                Enabled = true;
                Visible = true;



            }
        }
    }
    actions
    {
        addafter("C&alculate Counting Period")
        {
            action("Update TP Unit Cost_New")
            {
                ApplicationArea = All;
                Caption = 'Update "TP Unit Cost_New"';
                ToolTip = 'Update "TP Unit Cost_New"';
                Image = Action;

                trigger OnAction()
                var
                    //location: Record location;
                    item: Record Item;
                    SKU: Record "Stockkeeping Unit";
                    location: Record "Location";
                    TPcost: Decimal;
                begin
                    if SKU.FindFirst() then
                        repeat

                            if item.get(SKU."Item No.") then begin
                                if location.Get(SKU."Location Code") then begin
                                    //SKU."TP Unit Cost_New" := SKU."TP Unit Cost" - (SKU."TP Unit Cost") * item."Provisional Cost%" / 100;
                                    TPcost := SKU."Unit Cost" + (SKU."Unit Cost" * location."Inflated cost %") / 100;
                                    SKU."TP Unit Cost_New" := TPcost - (TPcost * item."Provisional Cost%") / 100;

                                    SKU.Modify();
                                end;
                            end;
                        until SKU.Next() = 0;


                end;

            }

            action("Delete Blank Code")
            {
                ApplicationArea = All;
                Caption = 'Delete Blank Code';
                ToolTip = 'Delete Blank Code';
                Image = Delete;

                trigger OnAction()
                var
                    SKU: Record "Stockkeeping Unit";
                begin
                    if SKU.FindFirst() then
                        repeat
                            if SKU."Item No." = 'TEST001' then begin
                                SKU.Delete();
                            end;
                        until SKU.Next() = 0;
                end;

            }

        }
    }



}
