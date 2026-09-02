namespace TigerpakBC.TigerpakBC;

page 70112 "Dangerous Goods"
{
    ApplicationArea = All;
    Caption = 'Dangerous Goods';
    PageType = List;
    SourceTable = "Dangerous Goods";
    SourceTableView = sorting(Code) order(ascending);

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
