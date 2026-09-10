namespace ALProject.ALProject;

using Microsoft.Warehouse.Structure;
using Microsoft.Warehouse.Ledger;

tableextension 70119 "Bin Content TExt" extends "Bin Content"
{
    fields
    {
        field(70100; "Blocked_Item"; Boolean)
        {
            Caption = 'Blocked Item';
            DataClassification = ToBeClassified;



        }

        field(70110; "HACCP Item"; Boolean)
        {
            Caption = 'HACCP Item';
            DataClassification = ToBeClassified;
            Editable = false;

        }

        field(70120; "Item Description"; Text[100])    // Cameron Valiantis Request
        {
            Caption = 'Item Description';
            DataClassification = ToBeClassified;
            Editable = false;

        }

        field(70121; "GIT Quantity"; Decimal)   //GIT Quantity - Justin
        {
            Caption = 'GIT Quantity';
            CalcFormula = sum("Warehouse Entry".Quantity where("Location Code" = const('GIT'),
                                                               "Item No." = field("Item No."),
                                                               "Variant Code" = field("Variant Code"),
                                                               "Unit of Measure Code" = field("Unit of Measure Code")));
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }
}
