namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Tracking;

reportextension 70109 "Lot No Label Ext" extends "Lot No Label"
{
    dataset
    {
        add("Lot No. Information")
        {
            column("Expiration_Date"; "Expiration Date") { }
        }
    }
}
