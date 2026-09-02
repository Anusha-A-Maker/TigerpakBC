table 70109 "Package Type_DG"
{
    Caption = 'Package Type_DG';
    DataClassification = ToBeClassified;
    LookupPageId = "Package Type_DG";

    fields
    {
        field(1; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(2; "Description"; Text[100])
        {
            Caption = '';
        }
    }
    keys
    {
        key(PK; "Name")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Name", "Description")
        {
        }
    }
}
