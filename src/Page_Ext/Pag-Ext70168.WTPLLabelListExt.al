namespace TigerpakBC.TigerpakBC;

pageextension 70168 "WTPL Label List Ext" extends "WTPL Label List"
{
  layout
  {
    addafter("WT Item No.")
    {
      field("Lot No."; Rec."Lot No.")
      {
        ApplicationArea = All;
        ToolTip = 'Specifies the lot number of the item.';
      }

      field("Expiry Date"; Rec."Expiry Date")
      {
        ApplicationArea = All;
        ToolTip = 'Specifies the expiry date of the item.';
      }
    }
  }
}
