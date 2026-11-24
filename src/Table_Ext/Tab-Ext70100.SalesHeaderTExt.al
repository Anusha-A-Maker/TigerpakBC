tableextension 70100 "Sales Header T-Ext" extends "Sales Header"
{
    fields
    {
        field(70100; OnHold; Boolean)
        {
            Caption = 'On Hold';
            DataClassification = ToBeClassified;
        }
        modify("On Hold")
        {
            Caption = ' On Hold Not in use';

        }

        field(70110; "Customer Grading"; Code[20])
        {

            Caption = 'Customer Grading';
            DataClassification = ToBeClassified;
            TableRelation = "Customer Grading";

        }

        field(70120; "Total Cost_New"; Decimal)
        {
            Caption = 'Total Cost_New';
            DataClassification = ToBeClassified;
        }

        field(70130; "Margin Amount_New"; Decimal)
        {
            Caption = 'Margin Amount_New';
            DataClassification = ToBeClassified;
        }

        field(70140; "Margin %_New"; Decimal)
        {
            Caption = 'Margin %_New';
            DataClassification = ToBeClassified;
        }


        modify("sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.get("Sell-to Customer No.") then begin
                    "Account Instructions" := Customer."Account Instructions";

                end;
            end;
        }

        field(70150; "Alt Address"; Text[200])
        {
            Caption = 'Alt Address';
            DataClassification = CustomerContent;
            Editable = false;

        }

        field(70301; "Auto Email - Post"; Boolean)
        {
            Caption = 'Auto Email - Post';
            DataClassification = ToBeClassified;
        }

        field(70310; "Quote Type"; Option)
        {
            Caption = 'Quote Type';
            DataClassification = ToBeClassified;
            OptionMembers = "RFQ - Request for Quote","CPL - Customer Price List","NBQ - New Business Quote"," ";

            trigger OnValidate()
            begin
                "Quote_Type_Text" := Format("Quote Type");
            end;

        }

        field(70320; "Quote Status"; Option)
        {
            Caption = 'Quote Status';
            DataClassification = ToBeClassified;
            OptionMembers = " ","Won","Lost";
            trigger OnValidate()
            begin
                "Quote_Outcome_Text" := Format("Quote Status");
            end;
        }

        modify("Quote Status")
        {
            trigger OnAfterValidate()
            begin
                Quote_Outcome_Text := Format("Quote Status");
                Rec.Modify();
            end;
        }

        field(70330; "Quote_Type_Text"; Text[50])
        {
            Caption = 'Quote Type Text';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        modify("Quote Type")
        {
            trigger OnAfterValidate()
            begin
                Quote_Type_Text := Format("Quote Type");
                if "Document Type" = "Document Type"::Quote then
                    if "Quote Type" = "Quote Type"::" " then
                        Error('Quote Type is mandatory for Quote document type');
                Rec.Modify();
            end;
        }

        field(70340; "Quote_Outcome_Text"; Text[50])
        {
            Caption = 'Quote Outcome Text';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70350; "Annualized Quote Figure"; Integer)
        {
            Caption = 'Annualized Quote Figure';
            fieldclass = FlowField;
            CalcFormula = Sum("Sales Line"."Annualized Quote Figure" where("Document Type" = field("Document Type"), "Document No." = field("No.")));
            editable = false;


        }





        modify("Ship-to post code")    //Alternate Shipping Address from Weborders when different from Sell-to Address
        {
            trigger OnAfterValidate()
            begin
                if Rec."Ship-to post code" <> Rec."Sell-to post code" then
                    //if rec."Ship-to Address" <> rec."Sell-to Address" then
                    rec."Alt Address" := 'Alternate Address'
                // else

                //         rec."Alt Address" := 'Alternate Address'
                else
                    rec."Alt Address" := '';
                Rec.Modify();

                if rec."Ship-to Address" <> rec."Sell-to Address" then
                    rec."Alt Address" := 'Alternate Address'

                else
                    rec."Alt Address" := '';
                Rec.Modify();

            end;
        }

        modify("Ship-to Address")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Ship-to Post code" <> Rec."Sell-to post code" then
                    rec."Alt Address" := 'Alternate Address'

                else
                    rec."Alt Address" := '';
                Rec.Modify();

                if rec."Ship-to Address" <> rec."Sell-to Address" then
                    rec."Alt Address" := 'Alternate Address'

                else
                    rec."Alt Address" := '';
                Rec.Modify();

            end;
        }

        modify("Sell-to Contact No.")   // #286 - Inactive Contact - To prevent selection of inactive contact in Customer Card
        {
            TableRelation = Contact Where("No." = field("Sell-to Contact No."), Status = filter('Active'));


            trigger OnAfterValidate()
            var
                ContactRec: Record Contact;
            begin
                if ContactRec.get(Rec."Sell-to Contact No.") then begin
                    if ContactRec.Status = 'Inactive' then
                        Error('This contact is inactive');
                end;
            end;
        }
        field(70400; "WHSE Shipment Created By"; Text[100])   //#298 - Sales Order/New field - Web Tracking
        {
            Caption = 'WHSE Shipment Created By';
            DataClassification = CustomerContent;
        }

        modify("Shipment Method Code")
        {
            trigger OnAfterValidate()
            var
                SL: Record "Sales Line";
            begin
                SL.SetRange("Document Type", Rec."Document Type"::Order);
                SL.SetRange("Document No.", Rec."No.");
                if SL.FindFirst() then begin
                    if SL."Backorder Status" = SL."Backorder Status"::Backorder then
                        Rec."Shipment Method Code" := 'delivery';
                end;
            end;
        }

        field(70410; "Claude Notes"; Text[500])
        {
            Caption = 'Claude Notes';
            DataClassification = CustomerContent;
        }

        field(70411; "Claude Notes Blob"; Blob)
        {
            Caption = 'Claude Notes';
            DataClassification = CustomerContent;
        }

    }




    procedure UpdateTPUnitCostNew(): Boolean
    var
        SalesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
        SKUrec: Record "Stockkeeping Unit";
        Confirm: Boolean;
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", Rec."Document Type");
        SalesHeader.SetRange("No.", Rec."No.");
        if SalesHeader.FindFirst() then begin
            salesLine.reset;
            salesLine.SetRange("Document Type", SalesHeader."Document Type");
            salesLine.SetRange("Document No.", SalesHeader."No.");
            if salesLine.findset() Then
                repeat
                    SKUrec.Reset();
                    SKUrec.SetRange("Item No.", salesLine."No.");
                    SKUrec.SetRange("Location Code", salesLine."Location Code");
                    if SKUrec.FindFirst() then
                        salesLine.Validate("TP Unit Cost_New", SKUrec."TP Unit Cost_New" * salesLine."Qty. per Unit of Measure")
                    else
                        salesLine.Validate("TP Unit Cost_New", salesLine."Unit Cost");
                    Confirm := salesLine.Modify();
                until salesline.Next() = 0;

        end;
        exit(confirm);
    end;

    trigger OnInsert()
    var
        SL: Record "Sales Line";
        TotalAnnualizedQuoteFigure: Decimal;
    begin
        "Quote_Type_Text" := Format("Quote Type");
        "Quote_Outcome_Text" := Format("Quote Status");


        // if Rec."Document Type" = Rec."Document Type"::Quote then begin
        //     Rec."Requested Delivery Date" := Today;
        // end;
    end;

    // trigger OnModify()
    // var
    //     SL: Record "Sales Line";
    //     TotalAnnualizedQuoteFigure: Decimal;
    // begin
    //     TotalAnnualizedQuoteFigure := 0;
    //     if Rec."Document Type" = Rec."Document Type"::Quote then begin
    //         SL.SetRange("Document Type", Rec."Document Type"::Quote);
    //         SL.SetRange("Document No.", Rec."No.");
    //         if SL.FindSet() then begin
    //             repeat
    //                 TotalAnnualizedQuoteFigure += SL."Annualized Quote Figure";

    //             until SL.Next() = 0;
    //             Rec."Annualized Quote Figure" := TotalAnnualizedQuoteFigure;
    //             Rec.Modify();
    //         end;
    //     end;
    // end;


}








