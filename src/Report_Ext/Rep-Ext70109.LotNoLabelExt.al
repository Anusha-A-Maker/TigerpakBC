namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Tracking;

reportextension 70109 "Lot No Label Ext" extends "Lot No Label"
{
    dataset
    {
        add("Lot No. Information")   //Expiration date field added to the dataset of Lot No. Label report - Justin
        {
            column("Expiration_Date"; "Expiration Date") { }
        }
    }
}
