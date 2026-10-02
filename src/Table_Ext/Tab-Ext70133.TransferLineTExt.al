namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Transfer;

tableextension 70133 "Transfer Line TExt" extends "Transfer Line"
{
    fields
    {
        field(70100; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = ToBeClassified;
        }
    }
}
