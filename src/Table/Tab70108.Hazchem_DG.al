table 70108 Hazchem_DG
{
    Caption = 'Hazchem_DG';
    DataClassification = ToBeClassified;
    lookupPageId = "Hazchem_DG";

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
