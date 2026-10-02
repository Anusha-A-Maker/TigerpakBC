namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Transfer;

pageextension 70167 "Transfer Order Subform Ext" extends "Transfer Order Subform"
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



    actions
    {
        addafter(ExplodeBOM_Functions)
        {
            action("Update Posting Date")
            {
                ApplicationArea = All;
                Caption = 'Update Posting Date';
                ToolTip = 'Update Posting Date';
                Image = Action;

                trigger OnAction()
                var
                    TransferHeader: Record "Transfer Header";
                begin
                    if TransferHeader.Get(Rec."Document No.") then begin
                        repeat
                            Rec."Posting Date" := TransferHeader."Posting Date";
                            Rec.Modify();
                        until Rec.Next() = 0;
                    end;
                end;
            }
        }
    }

    //     trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    //     var
    //         TransferHeader: Record "Transfer Header";
    //     begin
    //         Rec.SetRange("Document No.", TransferHeader."No.");
    //         if Rec.FindSet() then begin
    //             Rec."Posting Date" := TransferHeader."Posting Date";
    //             Rec.Modify();
    //         end;
    //     end;
}
