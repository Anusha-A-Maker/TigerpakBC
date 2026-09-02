namespace TigerpakBC.TigerpakBC;

page 70113 "Packing Group_DG"
{
    ApplicationArea = All;
    Caption = 'Packing Group_DG';
    PageType = List;
    SourceTable = "Packing Group_DG";
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
