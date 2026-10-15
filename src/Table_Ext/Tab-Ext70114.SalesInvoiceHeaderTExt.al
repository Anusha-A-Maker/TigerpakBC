namespace ALProject.ALProject;

using Microsoft.Sales.History;
using Microsoft.CRM.Contact;

tableextension 70114 "Sales Invoice Header TExt" extends "Sales Invoice Header"
{

    fields
    {
        field(70130; "Margin Amount_New"; Decimal)
        {
            Caption = 'Margin Amount_New';
            DataClassification = ToBeClassified;
        }

        field(70120; "Total Cost_New"; Decimal)
        {
            Caption = 'Total Cost_New';
            DataClassification = ToBeClassified;
        }


        field(70140; "Margin %_New"; Decimal)
        {
            Caption = 'Margin %_New';
            DataClassification = ToBeClassified;
        }
        field(70150; "Pick Duration in Mins"; Text[50])
        {
            Caption = 'Pick Duration in Mins';
            DataClassification = ToBeClassified;


        }
        field(70400; "WHSE Shipment Created By"; Text[100])
        {
            Caption = 'WHSE Shipment Created By';
            DataClassification = CustomerContent;
        }
        field(70160; "Sell-tocontact Email"; Text[100])
        {
            Caption = 'Sell-to Contact Email';
            FieldClass = FlowField;
            CalcFormula = Lookup(Contact."E-Mail" where("No." = field("Sell-to Contact No.")));
        }

        field(70161; "Bill-toContact Email"; Text[100])
        {
            Caption = 'Bill-to Contact Email';
            FieldClass = FlowField;
            CalcFormula = Lookup(Contact."E-Mail" where("No." = field("Bill-to Contact No.")));

        }

        field(70170; "Tracking Assigned At"; DateTime)
        {
            Caption = 'Package Tracking Assigned At';
            DataClassification = ToBeClassified;
        }
        modify("Package Tracking No.")
        {
            Caption = 'Package Tracking No.';
        }

    }

}
