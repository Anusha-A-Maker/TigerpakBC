namespace TigerpakBC.TigerpakBC;

using Microsoft.Warehouse.Document;

pageextension 70167 "Warehouse Shipment List Ext" extends "Warehouse Shipment List"
{

  layout
  {
    addafter(Status)
    {
      field("Order No."; Rec."Order No.")
      {
        ApplicationArea = All;
        Caption = 'Order No.';
      }

      field("Pick Created"; Rec.Pickcreated)
      {
        ApplicationArea = All;
        Caption = 'Pick Created.';
      }
    }
  }
}
