table 70110 "GIT Availability"
{
    Caption = 'GIT Availability';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; Location; Code[10])
        {
            Caption = 'Location';
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
        }
        field(3; Item; Code[20])
        {
            Caption = 'Item';
            DataClassification = ToBeClassified;
            TableRelation = Item."No.";
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(5; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(6; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
        }
        field(7; "Receiving Location"; Code[10])
        {
            Caption = 'Receiving Location';
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
        }
        field(8; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK1; "Entry No.")
        {
            Clustered = true;
        }
        key(PK2; "Document No.")
        {
            Clustered = false;
        }
    }
}
