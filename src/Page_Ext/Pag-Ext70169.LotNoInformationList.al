namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Tracking;

pageextension 70169 "Lot No. Information List" extends "Lot No. Information List"
{
    layout
    {
        addafter(Blocked)
        {
            field("Expiration Date"; Rec."Expiration Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the expiration date of the lot number.';
            }
            field("Quantity"; Rec."Quantity")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity for this item, variant, and lot number.';
            }
        }

    }

    actions
    {
        addlast(Processing)
        {
            action(PrintLotLabelsByQuantity)
            {
                ApplicationArea = All;
                Caption = 'Print Lot Labels by Quantity';
                Image = Print;
                ToolTip = 'Print one lot label for each unit in the selected lot quantity.';

                trigger OnAction()
                var
                    SelectedLotNoInformation: Record "Lot No. Information";
                    LotNoLabelByQuantity: Report "Lot No Label by Quantity";
                begin
                    CurrPage.SetSelectionFilter(SelectedLotNoInformation);
                    LotNoLabelByQuantity.SetTableView(SelectedLotNoInformation);
                    LotNoLabelByQuantity.RunModal();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Quantity");
    end;
}

