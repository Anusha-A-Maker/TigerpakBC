table 70105 "Dangerous Goods"
{
    Caption = 'Dangerous Goods';
    DataClassification = ToBeClassified;
    LookupPageId = "Dangerous Goods";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Code", "Description")
        {
        }
    }
}
