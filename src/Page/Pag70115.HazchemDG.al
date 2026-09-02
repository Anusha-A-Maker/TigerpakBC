namespace TigerpakBC.TigerpakBC;

page 70115 Hazchem_DG
{
    ApplicationArea = All;
    Caption = 'Hazchem_DG';
    PageType = List;
    SourceTable = Hazchem_DG;
    SourceTableView = sorting("Code") order(ascending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; rec."Code")
                {
                    ApplicationArea = All;
                    Caption = 'Code';
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
