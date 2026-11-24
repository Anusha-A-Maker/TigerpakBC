namespace ALProject.ALProject;

using Microsoft.Sales.History;

pageextension 70137 "Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Packed By")
        {
            field("WHSE Shipment Created By"; Rec."WHSE Shipment Created By")
            {
                ApplicationArea = All;
                Caption = 'WHSE Shipment Created By';
                ToolTip = 'Specifies the user that created the warehouse shipment for the posted sales invoice.';
            }

            field("Tracking Assigned At"; Rec."Tracking Assigned At")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies when the package tracking number was last assigned to the posted sales invoice.';
            }
        }
        addafter("Work Description")
        {
            group("ClaudeNotes")
            {
                Caption = 'Claude Notes';
                field(ClaudeNotesText; ClaudeNotesText)
                {
                    ApplicationArea = all;
                    Caption = 'Claude Notes';
                    Style = Favorable;
                    Editable = false;
                    MultiLine = true;
                }
            }
        }
    }

    var
        ClaudeNotesText: Text;


}
