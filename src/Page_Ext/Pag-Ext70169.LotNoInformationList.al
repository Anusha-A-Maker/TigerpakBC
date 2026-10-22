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
    }
      
      }
    }
  

