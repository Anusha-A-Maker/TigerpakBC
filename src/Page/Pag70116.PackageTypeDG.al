namespace TigerpakBC.TigerpakBC;

page 70116 "Package Type_DG"
{
    ApplicationArea = All;
    Caption = 'Package Type_DG';
    PageType = List;
    SourceTable = "Package Type_DG";
    SourceTableView = sorting("Name") order(ascending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Name"; rec."Name")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                }
                field("Description"; rec."Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
            }
        }
    }
}
