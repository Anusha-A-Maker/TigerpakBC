table 70106 "Packing Group_DG"
{
    Caption = 'Packing Group_DG';
    DataClassification = ToBeClassified;
    LookupPageId = "Packing Group_DG";

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
