namespace TigerpakBC.TigerpakBC;

page 70114 Shipping_DG
{
    ApplicationArea = All;
    Caption = 'Shipping_DG';
    PageType = List;
    SourceTable = Shipping_DG;
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
