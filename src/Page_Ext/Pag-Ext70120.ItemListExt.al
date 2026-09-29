namespace ALProject.ALProject;

using Microsoft.Inventory.Item;

pageextension 70120 "Item List Ext" extends "Item List"
{
    layout
    {
        addafter("Unit Price")
        {
            field("IA_Custom002"; Rec."IA_Custom002")
            {
                Caption = 'IA_Custom002';
                ApplicationArea = All;

            }
            field(Classification; Rec.Classification)
            {
                Caption = 'Classification';
                ApplicationArea = All;
            }
        }
        addafter("Item Category Code")
        {
            field("Item Category Group"; Rec."Item Category Group")
            {
                Caption = 'Item Category Group';
                ApplicationArea = All;
            }
            field("Exclude-Plytix"; Rec."Exclude-Plytix")  //Exclude-Plytix field added to Item list page for Web Services ItemsAzure- Tommy
            {
                Caption = 'Exclude-Plytix';
                ApplicationArea = All;
            }

        }

        addafter("Vendor No.")  // fields added to Item list page for Web Services - Greg
        {
            field("HACCP Item"; Rec."HACCP Item")
            {
                Caption = 'HACCP Item';
                ApplicationArea = All;
            }
            field("Must Always Be in Stock"; Rec."Must Always Be in Stock")
            {
                Caption = 'Must Always Be in Stock';
                ApplicationArea = All;
            }
            field("Pallet Qty"; Rec."Pallet Qty")
            {
                Caption = 'Pallet Qty';
                ApplicationArea = All;
            }
            field(BOMH; Rec.BOMH)
            {
                Caption = 'BOMH';
                ApplicationArea = All;
            }
            field(BOML; Rec.BOML)
            {
                Caption = 'BOML';
                ApplicationArea = All;
            }
            field(BOMW; Rec.BOMW)
            {
                Caption = 'BOMW';
                ApplicationArea = All;
            }
            field(BOMWT; Rec.BOMWT)
            {
                Caption = 'BOMWT';
                ApplicationArea = All;
            }
            field(BGPrice; Rec.BGPrice)
            {
                Caption = 'BG Price';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addafter(AdjustInventory)
        {
            action("Update_Stocking_Indicator")
            {
                ApplicationArea = All;
                Caption = 'Update Stocking Indicator';
                Image = Action;

                trigger OnAction()
                var
                    Item: Record "Item";
                begin
                    Item.Reset();
                    //Item.SetRange("No.", Rec."No.");
                    Item.SetRange(Classification, Rec.Classification::DISCONTINUED);
                    if Item.FindFirst() then
                        repeat
                            Item."IA_Custom002" := Rec."IA_Custom002"::"Obsolete (O)";
                            Item.Modify();
                        until Item.Next() = 0;
                end;
            }
        }
    }
}
