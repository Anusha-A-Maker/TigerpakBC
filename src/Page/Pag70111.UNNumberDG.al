namespace TigerpakBC.TigerpakBC;

page 70111 "UN Number_DG"
{
    ApplicationArea = All;
    Caption = 'UN Number_DG';
    PageType = List;
    SourceTable = "UN Number_DG";
    SourceTableView = sorting("No.") order(ascending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("No."; rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
            }
        }
    }
}
