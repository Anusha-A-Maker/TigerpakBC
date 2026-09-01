pageextension
70108 "Item Card_Ext" extends "Item Card"
{
    layout
    {
        addafter("Item Category Code")
        {
            field("Item Category Group"; Rec."Item Category Group")
            {
                ApplicationArea = All;
                Caption = 'Item Category Group';
                ToolTip = 'Item Category Group';
                Editable = true;
                Enabled = true;
                Visible = true;



            }


        }
        addbefore("VAT Prod. Posting Group")
        {
            field("Gen. Prod. Posting Group New"; Rec."Gen. Prod. Posting Group new")
            {
                ApplicationArea = All;
                Caption = 'Gen. Prod. Posting Group New';
                ToolTip = 'Gen. Prod. Posting Group New';
                Editable = true;
                Enabled = true;
                Visible = true;
                // trigger OnLookup(var Text: Text): Boolean
                // var
                //     GenProdPostingGroup: Record "Gen. Product Posting Group";
                // begin
                //     GenProdPostingGroup.SetRange("Item Category Group", Rec."Item Category Group");

                //     //GenProdPostingGroup.GetSet(true);
                //     //if GenProdPostingGroup.FindFirst() then begin
                //     if page.RunModal(Page::"Gen. Product Posting Groups", GenProdPostingGroup) = Action::LookupOK then begin
                //         Rec."Gen. Prod. Posting Group" := GenProdPostingGroup."Code";
                //     end;
                // end;
                //TableRelation = "Gen. Product Posting Group".code where("Item Category Group" = field("Item Category Group"));
            }
        }

        modify("Gen. Prod. Posting Group")
        {
            Visible = false;
            //TableRelation = "Gen. Product Posting Group".code where("Item Category Group" = field("Item Category Group"));
        }


        addafter("Purch. Unit of Measure")
        {
            field("Purchase Order Multiples"; Rec."Purchase Order Multiples")
            {
                ApplicationArea = All;
                Caption = 'Purchase Order Multiples';
                ToolTip = 'Purchase Order Multiples';
                Editable = true;
                Enabled = true;
                Visible = true;
                TableRelation = "Item Unit of Measure".code where("item no." = field("no."), Code = field("Purchase Order Multiples"));
            }

        }


        addafter("Expiration Calculation")
        {
            field("HACCP Item"; Rec."HACCP Item")
            {
                ApplicationArea = All;
                Caption = 'HACCP Item';
                ToolTip = 'HACCP Item';
                Editable = true;
                Enabled = true;
                Visible = true;
            }
        }
        addlast(content)
        {
            group("Related")
            {
                Caption = 'Related';

                field("US-Agreed Usage"; Rec."US-Agreed Usage")
                {
                    Caption = 'US-Agreed Usage';
                    ApplicationArea = All;

                }

                field("US-Actual Usage"; Rec."US-Actual Usage")
                {
                    Caption = 'US-Actual Usage';
                    ApplicationArea = All;

                }
                field("US- Agreement Start Date"; Rec."US- Agreement Start Date")
                {
                    Caption = 'US-Agreement Start Date';
                    ApplicationArea = All;

                }
                field("US-Expiry Date"; Rec."US-Expiry Date")
                {
                    Caption = 'US-Expiry Date';
                    ApplicationArea = All;

                }
                field("US-Agreed Months Stock on Hand"; Rec."US-Agreed Months Stock on Hand")
                {
                    Caption = 'US-Agreed Months Stock on Hand';
                    ApplicationArea = All;

                }
                field("US-Actual Stock on Hand"; Rec."US-Actual Stock on Hand")
                {
                    Caption = 'US-Actual Stock on Hand';
                    ApplicationArea = All;

                }
            }

            group("Dangerous Goods")
            {
                Caption = 'Dangerous Goods';

                field("UN No."; Rec."UN No.")
                {
                    Caption = 'UN No.';
                    ApplicationArea = All;

                }
                field("Dangerous Goods Code"; Rec."Dangerous Goods Code")
                {
                    Caption = 'Dangerous Goods Code';
                    ApplicationArea = All;

                }
                field("Packing Group"; Rec."Packing Group")
                {
                    Caption = 'Packing Group';
                    ApplicationArea = All;

                }
                field("Shipping Name"; Rec."Shipping Name")
                {
                    Caption = 'Shipping Name';
                    ApplicationArea = All;

                }
                field("Hazchem Code"; Rec."Hazchem Code")
                {
                    Caption = 'Hazchem Code';
                    ApplicationArea = All;

                }
                field("Package Type"; Rec."Package Type")
                {
                    Caption = 'Package Type';
                    ApplicationArea = All;

                }
                field("Pack Quantity"; Rec."Pack Quantity")
                {
                    Caption = 'Pack Quantity';
                    ApplicationArea = All;

                }

            }


        }

        addlast("Costs & Posting")
        {
            field("Provisional Cost%"; Rec."Provisional Cost%")
            {
                Caption = 'Provisional Cost%';
                ApplicationArea = All;
                ToolTip = 'Provisional Cost%';
                Editable = true;
                Enabled = true;
                Visible = true;
            }
        }
        addafter("Vendor Item No.")
        {
            field("Secondary Vendor No."; Rec."Secondary Vendor No.")
            {
                ApplicationArea = All;
                Caption = 'Secondary Vendor No.';
                ToolTip = 'Secondary Vendor No.';

            }
        }

        addbefore("US-Agreed Usage")
        {
            field("Customer Code"; Rec."Customer Code")
            {
                ApplicationArea = All;
                Caption = 'Customer Code';
                ToolTip = 'Customer Code';

            }
        }

        // modify("Purchase MOQ")
        // {
        //     trigger OnAfterValidate()
        //     var
        //         SKU: Record "Stockkeeping Unit";
        //     begin
        //         SKU.SetRange("Item No.", Rec."No.");
        //         if SKU.FindSet() then begin
        //             if Confirm('Do you want to update the Purchase MOQ for all SKUs related to this item?', true) then
        //                 repeat
        //                     SKU."Purchase MOQ" := Rec."Purchase MOQ";
        //                     SKU.Modify(true);
        //                 until SKU.Next() = 0;
        //            // SKU.ModifyAll("Purchase MOQ", Rec."Purchase MOQ");

        //         end;
        //     end;
        // }
    }

}
