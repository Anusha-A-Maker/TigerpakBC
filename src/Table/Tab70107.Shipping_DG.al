table 70107 Shipping_DG
{
    Caption = 'Shipping_DG';
    DataClassification = ToBeClassified;
    lookupPageId = "Shipping_DG";

    fields
    {
        field(1; "Name"; Text[100])
        {
            Caption = 'Name';
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
