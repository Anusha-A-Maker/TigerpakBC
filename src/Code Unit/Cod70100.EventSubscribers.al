codeunit 70100 "EventSubscribers1"
{
    Permissions = tabledata 110 = RMID, tabledata 7322 = RMID, tabledata 121 = RMID, tabledata 112 = RIMD, tabledata 114 = rmid, tabledata 21 = rmid, tabledata 113 = rmid, tabledata 5772 = rmid;




    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Inv. - Update", OnAfterRecordChanged, '', false, false)]
    local procedure OnAfterRecordChanged(var SalesInvoiceHeader: Record "Sales Invoice Header"; xSalesInvoiceHeader: Record "Sales Invoice Header"; var IsChanged: Boolean)
    begin

        IsChanged := (SalesInvoiceHeader."Payment Terms Code" <> xSalesInvoiceHeader."Payment Terms Code") or (SalesInvoiceHeader."External Document No." <> xSalesInvoiceHeader."External Document No.") or (SalesInvoiceHeader."due date" <> xSalesInvoiceHeader."Due Date") or
       (SalesInvoiceHeader."Posting Description" <> xSalesInvoiceHeader."Posting Description") or (SalesInvoiceHeader."Promised Pay Date" <> xSalesInvoiceHeader."Promised Pay Date") or
       (SalesInvoiceHeader."Dispute Status" <> xSalesInvoiceHeader."Dispute Status") or (SalesInvoiceHeader."Payment Method Code" <> xSalesInvoiceHeader."Payment Method Code") or
       (SalesInvoiceHeader."Payment Reference" <> xSalesInvoiceHeader."Payment Reference") or (SalesInvoiceHeader."Company Bank Account Code" <> xSalesInvoiceHeader."Company Bank Account Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Inv. Header - Edit", OnRunOnBeforeAssignValues, '', false, false)]
    local procedure OnRunOnBeforeAssignValues(var SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceHeaderRec: Record "Sales Invoice Header")
    begin

        SalesInvoiceHeader."Payment Terms Code" := SalesInvoiceHeaderRec."Payment Terms Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", OnAfterRegisteredWhseActivHeaderInsert, '', false, false)]


    local procedure OnAfterRegisteredWhseActivHeaderInsert(var RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr."; WarehouseActivityHeader: Record "Warehouse Activity Header")

    var

        // WarehouseActivityLine: Record "Warehouse Activity Line";

        registedWhseActivityLine: Record "Registered Whse. Activity Line";

        PickDurationMinutes: Text;

    begin
        if WarehouseActivityHeader.Type = WarehouseActivityHeader.Type::Pick then begin // Only to update for Pick type

            RegisteredWhseActivityHdr."Pick Completed Date time" := CurrentDateTime(); // To capture the pick completed date time
            RegisteredWhseActivityHdr."Pick Duration" := RegisteredWhseActivityHdr."Pick Completed Date time" - RegisteredWhseActivityHdr."Pick Created Date time"; // To calculate the pick duration in minutes

            PickDurationMinutes := Format(RegisteredWhseActivityHdr."Pick Duration" div 60000);
            RegisteredWhseActivityHdr."Pick Duration in Min" := PickDurationMinutes;

            registeredWhseActivityHdr.Modify();
        end;

    end;
    // To update the Source No. from Registered Whse. Activity Line to Registered Whse. Activity Header
    //registedWhseActivityLine.Reset();
    // registedWhseActivityLine.SetRange("No.", RegisteredWhseActivityHdr."No.");
    // if registedWhseActivityLine.FindFirst() then begin
    //     RegisteredWhseActivityHdr."Source No." := registedWhseActivityLine."Source No.";
    //     RegisteredWhseActivityHdr.Modify();
    // end;





    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", OnAfterRegisteredWhseActivLineInsert, '', false, false)]
    local procedure OnAfterRegisteredWhseActivLineInsert(var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr.";

    begin
        // To update the Source No. from Registered Whse. Activity Line to Registered Whse. Activity Header
        repeat
            RegisteredWhseActivityHdr.SetRange("No.", RegisteredWhseActivityLine."No.");
            if RegisteredWhseActivityHdr.FindFirst() then
                RegisteredWhseActivityHdr."Source No." := RegisteredWhseActivityLine."Source No.";
            RegisteredWhseActivityHdr.Modify();
        until RegisteredWhseActivityLine.Next() = 0;

    end;








    procedure UpdateAllSN()
    var
        RWAH: Record "Registered Whse. Activity Hdr.";
        RWAL: Record "Registered Whse. Activity Line";
        window: Dialog;
    begin
        window.Open('Updating Source No.#1 in Registered Whse. Activity Hdr.');

        RWAH.Reset();
        RWAH.SetRange("Source No.", '');
        if RWAH.FindSet() then
            repeat
                window.Update(1, RWAH."No.");
                RWAL.SetRange("No.", RWAH."No.");
                if RWAL.FindFirst() then begin
                    RWAH."Source No." := RWAL."Source No.";
                    RWAH.Modify();
                end;
            until RWAH.Next() = 0;
        window.Close();
    end;


    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", OnValidateReceiptDateOnBeforeCalcShipmentDate, '', false, false)]

    local procedure OnValidateReceiptDateOnBeforeCalcShipmentDate(var IsHandled: Boolean; var TransferHeader: Record "Transfer Header")
    begin

        IsHandled := true;


    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", OnValidateShipmentDateOnBeforeCalcReceiptDate, '', false, false)]
    local procedure OnValidateShipmentDateOnBeforeCalcReceiptDate(var IsHandled: Boolean; var TransferHeader: Record "Transfer Header")
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnBeforeOnInsert, '', false, false)]
    local procedure OnBeforeOnInsert(var TransferLine: Record "Transfer Line"; var xTransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; var IsHandled: Boolean)



    begin
        if TransferHeader.Get(TransferLine."Document No.") then
            TransferLine."Posting Date" := TransferHeader."Posting Date";
    end;





    procedure UpdateAllNPS()
    var
        SIH: Record "Sales Invoice Header";
    begin
        SIH.Reset();
        // SIH.SetRange("No.", 'SINV-025745', 'SINV-025759');
        if SIH.Findset() then
            SIH.ModifyAll("WT Sent to NPS", true);
        // repeat
        //     SIH."WT Sent to NPS" := false;
        //     SIH.Modify();
        // until SIH.Next() = 0;
    end;

    procedure Updateprinted(DocumentNo: Code[20])
    var
        SSH: Record "Sales Shipment Header";
    begin
        if SSH.Get(DocumentNo) then begin
            SSH."No. Printed" += 1;
            SSH.Modify();
        end;

    end;

    procedure UpdateAllPrintedINV(DocumentNo: Code[20])
    var
        SIH: Record "Sales Invoice Header";
    begin
        if SIH.Get(DocumentNo) then begin
            SIH."No. Printed" += 1;
            SIH.Modify();
        end;

    end;






    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeModifyEvent, '', false, false)]
    local procedure MyProcedure(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; RunTrigger: Boolean)
    var
        Users: Record User;
    begin
        if Users.get(Rec.SystemModifiedBy) then begin
            Rec."Modified By" := Users."User Name";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Source Doc. Outbound", 'OnAfterCreateWhseShipmentHeaderFromWhseRequest', '', false, false)]
    local procedure OnAfterCreateWhseShipmentHeaderFromWhseRequest(var WarehouseRequest: Record "Warehouse Request"; var WhseShptHeader: Record "Warehouse Shipment Header")
    var

        SH: Record "Sales Header";
        WHSELine: Record "Warehouse Shipment Line";
        QstnLbl: Text;
    begin
        WHSELine.Reset();
        WHSELine.SetRange("No.", WhseShptHeader."No.");
        if WHSELine.FindFirst() then begin
            if SH.Get(SH."Document Type"::Order, WHSELine."Source No.") then begin
                SH.Reset();
                SH.SetRange("No.", WHSELine."Source No.");
                if SH.FindFirst() then begin
                    // if SH."Location Code" <> SH."Ship-to County" then
                    //     QstnLbl := StrSubstNo('The Location Code %1 is different from Ship-to County %2. Do you want to continue?', SH."Location Code", SH."Ship-to County");
                    // if not Confirm(QstnLbl) then
                    //     exit
                    // else
                    SH.Validate("WHSE Shipment Created By", UserId());   //#298 - Sales Order/New field - Web Tracking
                    SH.Modify();
                    //     WhseShptHeader."Your Reference" := SH."Your Reference";  // Copying Your Reference from sales order to wshe shipments for web services API
                    //     if CopyStr(WhseShptHeader."Your Reference", 1, 3) = 'WEB' then
                    //         WhseShptHeader."Web Order No." := CopyStr(WhseShptHeader."Your Reference", 4)  // Web order number from sales order for web services
                    //     else
                    //         WhseShptHeader."Web Order No." := '';
                end;

            end;
        end;
        WhseShptHeader.Reset();
        WhseShptHeader.SetRange("Order No.", SH."No.");
        if WhseShptHeader.FindFirst() then begin
            WhseShptHeader."Your Reference" := SH."Your Reference";  // Copying Your Reference from sales order to wshe shipments for web services API
            if CopyStr(WhseShptHeader."Your Reference", 1, 3) = 'WEB' then
                WhseShptHeader."Web Order No." := CopyStr(WhseShptHeader."Your Reference", 4)  // Web order number from sales order for web services
            else
                WhseShptHeader."Web Order No." := '';
            WhseShptHeader.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", OnBeforePostedWhseShptHeaderInsert, '', false, false)]
    local procedure OnBeforePostedWhseShptHeaderInsert(var PostedWhseShipmentHeader: Record "Posted Whse. Shipment Header"; WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        PostedWhseShipmentHeader."Your Reference" := WarehouseShipmentHeader."Your Reference";  // Copying Your Reference from sales order to posted wshe shipments for web services API
        PostedWhseShipmentHeader."Web Order No." := WarehouseShipmentHeader."Web Order No.";  // Copying Web Order No. from sales order to posted wshe shipments for web services API   
    end;




    // local procedure OnBeforeCreateFromSalesOrder(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    // begin
    //     SalesHeader.Validate("WHSE Shipment Created By", UserId());   //#298 - Sales Order/New field - Web Tracking
    //     SalesHeader.Modify();
    // end;




    [EventSubscriber(ObjectType::Codeunit, codeunit::"Sales-Post", OnAfterFinalizePosting, '', true, true)]
    local procedure OnAfterFinalizePosting(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var
        SalesCrMemoHeader2: Record "Sales Cr.Memo Header";
        SalesCrMemoLine2: Record "Sales Cr.Memo Line";
        salesinvoiceheader2: Record "Sales Invoice Header";
        SalesInvoiceline2: Record "Sales Invoice Line";
        salesHeader2: Record "Sales Header";

        SIH: Record "Sales Invoice Header";
        RWAH: Record "Registered Whse. Activity Hdr.";
    begin
        if SalesCrMemoHeader2.Get(SalesCrMemoHeader."No.") then begin
            SalesCrMemoLine2.SetRange("Document No.", SalesCrMemoHeader."No.");
            if SalesCrMemoLine2.FindSet() then
                repeat
                    SalesCrMemoHeader2."Total Cost" += SalesCrMemoLine2."Unit Cost (LCY)" * SalesCrMemoLine2."Quantity";
                until SalesCrMemoLine2.Next() = 0;
            SalesCrMemoHeader2.CalcFields(Amount);


            SalesCrMemoHeader2."Margin Amount" := SalesCrMemoHeader2.Amount - SalesCrMemoHeader2."Total Cost";
            if SalesCrMemoHeader2.Amount <> 0 then
                SalesCrMemoHeader2."Margin %" := (SalesCrMemoHeader2."Margin Amount" / SalesCrMemoHeader2.Amount) * 100;
            SalesCrMemoHeader2.Modify();


        end;


        if SalesInvoiceHeader2.get(salesinvoiceheader."No.") then begin
            SalesInvoiceline2.SetRange("Document No.", SalesInvoiceHeader2."No.");
            SalesInvoiceline2.SetFilter(Quantity, '<>0');
            if salesinvoiceline2.FindSet() then
                repeat
                    salesinvoiceheader2."Total Cost_New" += SalesInvoiceline2."TP Unit Cost_New" * SalesInvoiceline2.Quantity;
                until SalesInvoiceline2.Next() = 0;
            SalesInvoiceHeader2.CalcFields(Amount, "Amount Including VAT");
            salesinvoiceheader2."Margin Amount_New" := salesinvoiceheader2."Amount" - salesinvoiceheader2."Total Cost_New";
            if salesinvoiceheader2."Amount" <> 0 then
                salesinvoiceheader2."Margin %_New" := (salesinvoiceheader2."Margin Amount_New" / salesinvoiceheader2."Amount") * 100;

            // salesinvoiceheader2."Margin Amount_New" := salesinvoiceheader2.Amount - salesinvoiceheader2."Total Cost_New";
            // salesinvoiceheader2."Margin %_New" := (salesinvoiceheader2."Margin Amount_New" / salesinvoiceheader2.Amount) * 100;
            salesinvoiceheader2.Modify();
        end;

        // To update the Pick Duration in Mins from Registered Whse. Activity Hdr. to Sales Invoice Header
        if SIH.Get(SalesInvoiceHeader."No.") then begin
            RWAH.SetRange("Source No.", SIH."Order No.");
            if RWAH.FindFirst() then begin
                SIH."Pick Duration in Mins" := RWAH."Pick Duration in Min";
                SIH.Modify();
            end;
        end;

        SalesInvoiceline2.SetRange("Document No.", SalesInvoiceHeader."No.");  // #290 Posted Sales Invoice Lines - External Document No. field update from Sales Invoice Header
        if SalesInvoiceline2.FindSet() then
            repeat
                SalesInvoiceline2."External Document No." := SalesInvoiceHeader."External Document No.";
                SalesInvoiceline2.Modify();
            until SalesInvoiceline2.Next() = 0;



    end;

    procedure UpdatePickDuration()
    var
        SIH: Record "Sales Invoice Header";
        RWAH: Record "Registered Whse. Activity Hdr.";
        window: Dialog;
    begin
        window.Open('Updating Pick Duration in Mins in Sales Invoice Header from Registered Whse. Activity Hdr.#1');
        SIH.Reset();
        SIH.SetRange("Pick Duration in Mins", '');
        if SIH.FindSet() then
            repeat
                window.Update(1, SIH."No.");
                RWAH.SetRange("Source No.", SIH."Order No.");
                if RWAH.FindFirst() then begin
                    SIH."Pick Duration in Mins" := RWAH."Pick Duration in Min";
                    SIH.Modify();
                end;
            until SIH.Next() = 0;
        window.Close();
    end;



    [EventSubscriber(ObjectType::Codeunit, codeunit::"Sales-Post", OnAfterSalesCrMemoHeaderInsert, '', true, true)]
    local procedure OnAfterSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; WhseShip: Boolean; WhseReceive: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header"; var TempWhseRcptHeader: Record "Warehouse Receipt Header")
    begin
        //SalesCrMemoHeader.SetRange("Pre-Assigned No.", SalesHeader."No.");
        //if SalesCrMemoHeader.findfirst() then begin
        if SalesCrMemoHeader."Auto Email - Post" then begin
            SalesCrMemoHeader.SetRecFilter();
            salesCrMemoHeader.EmailRecords(false);
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, codeunit::"Sales-Post", OnAfterPostSalesDoc, '', true, true)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    // begin
    // end;

    // [EventSubscriber(ObjectType::Codeunit, codeunit::"Sales-Post", OnAfterInsertCrMemoHeader, '', true, true)]
    // local procedure OnAfterInsertCrMemoHeader(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        Contact: Record Contact;
        EmailMsg: Codeunit "Email Message";
        Email: Codeunit "Email";
        CreditMemoReport: Report "TP Custom Sales Cr. Memo";
        TempBlob: Codeunit "Temp Blob";
        TempBlob1: Codeunit "Temp Blob";
        OutStream: OutStream;
        Outstr1: OutStream;
        InStream: InStream;
        Instr1: InStream;
        FileName: Text;
        SCHRecRef: RecordRef;
        ReportParameters: text;
        SalesCrMemoHeader2: Record "Sales Cr.Memo Header";
        reportselection: Record "Report Selections";
        EmailBody: Text;
        subject: Text[100];
    begin
        SalesCrMemoHeader2.reset;
        SalesCrMemoHeader2.SetFilter("No.", SalesCrMemoHdrNo);
        if SalesCrMemoHeader2.FindFirst() then
            if SalesCrMemoHeader2."Auto Email - Post" then begin     //#254 - Auto Email Credit Memo on Post of CR/SRO - emailing to customer's default contact email

                if Customer.Get(SalesCrMemoHeader2."Sell-to Customer No.") then begin
                    // Get Primary Contact
                    if Contact.Get(Customer."Primary Contact No.") then begin
                        if Contact."E-Mail" <> '' then begin
                            // Generate Credit Memo PDF into TempBlob

                            TempBlob.CreateOutStream(OutStream);
                            TempBlob1.CreateOutStream(Outstr1);
                            reportselection.reset;
                            reportselection.setrange(Usage, reportselection.Usage::"S.Cr.Memo");
                            reportselection.SetRange(Sequence, '1');
                            if reportselection.FindFirst() then;

                            CreditMemoReport.SetTableView(SalesCrMemoHeader2);
                            ReportParameters := '';

                            // Prepare InStream for attachment

                            FileName := 'CreditMemo_' + SalesCrMemoHeader2."No." + '.pdf';

                            // Create and Send Email
                            // EmailMsg.Create(Contact."E-Mail",
                            //                 'Credit Memo ' + SalesCrMemoHeader2."No.",
                            //                 'Dear ' + Contact.Name + ',<br><br>Please find attached your credit note.<br><br>Regards,<br>Your Company');
                            SCHRecRef.GetTable(SalesCrMemoHeader2);
                            //Report.SaveAs(reportselection."Report ID", ReportParameters, ReportFormat::Html, OutStr1, SCHRecRef);
                            TempBlob1.CreateInStream(InStr1);
                            InStr1.Readtext(EmailBody);
                            subject := 'Tigerpak - Sales Credit Memo ' + SalesCrMemoHeader2."No.";
                            EmailMsg.Create(Contact."E-Mail", subject, EmailBody, True);



                            Report.SaveAs(reportselection."Report ID", ReportParameters, ReportFormat::Pdf, OutStream, SCHRecRef);

                            //CreditMemoReport.SaveAs('', ReportFormat::Pdf, OutStream, SCHRecRef);
                            TempBlob.CreateInStream(InStream);
                            EmailMsg.AddAttachment(FileName, FileName, InStream);
                            Email.Send(EmailMsg, Enum::"Email Scenario"::"Sales Credit Memo");
                        end;
                    end;
                end;
            end;
    end;





    //     if SalesCrMemoHeader."Auto Email - Post" then begin   //#254 - Auto Email Credit Memo on Post of CR/SRO - emailing to customer's sell-to email
    //         SalesCrMemoHeader.SetRecFilter();
    //         salesCrMemoHeader.EmailRecords(false);
    //     end;
    // end;




    //end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Assembly Line Management", OnAfterUpdateAssemblyLines, '', true, true)]
    local procedure OnAfterUpdateAssemblyLines(var AsmHeader: Record "Assembly Header"; OldAsmHeader: Record "Assembly Header"; FieldNum: Integer; ReplaceLinesFromBOM: Boolean; CurrFieldNo: Integer; CurrentFieldNum: Integer)
    var
        asmLine: Record "Assembly Line";
    begin
        if FieldNum = AsmHeader.FieldNo("Location Code") then begin
            AsmHeader.CreateDimFromDefaultDim();
            asmLine.SetRange("Document No.", AsmHeader."No.");
            if asmLine.FindSet() then
                repeat
                    asmLine.Validate("Location Code", AsmHeader."Location Code");
                    asmLine.Modify();
                until asmLine.Next() = 0;
        end;
    end; //Validate location code change in assembly order header to update in assembly lines with dimensions   











    [EventSubscriber(ObjectType::Codeunit, codeunit::"Sales-Post", OnAfterPostSalesLines, '', true, true)]

    procedure OnAfterPostSalesLines(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; WhseShip: Boolean; WhseReceive: Boolean; var SalesLinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingInvoiced: Boolean; var TempSalesLineGlobal: Record "Sales Line" temporary)

    var
        salesinvline: Record "Sales Invoice Line";


    begin
        salesinvline.SetRange("Document No.", TempSalesLineGlobal."Document No.");
        Salesinvline.SetRange("No.", TempSalesLineGlobal."No.");
        Salesinvline.SetRange("Location Code", TempSalesLineGlobal."Location Code");
        if salesinvline.FindSet() then
            repeat
                salesinvline."TP Unit Cost_New" := TempSalesLineGlobal."TP Unit Cost_New";
                salesinvline."Salesperson Code" := SalesInvoiceHeader."Salesperson Code";
                salesinvline.Modify();
            until salesinvline.Next() = 0;
        salesinvline.SetRange("Document No.", SalesInvoiceHeader."Salesperson Code");
        if salesinvline.FindSet() then
            repeat
                salesinvline."Salesperson Code" := SalesInvoiceHeader."Salesperson Code";
                salesinvline.Modify();
            until salesinvline.Next() = 0;
    end;

    procedure UpdateAllTPUnitCostNew()
    var
        SKU: Record "Stockkeeping Unit";
        //SalesLine: Record "Sales Line";
        Salesinvline: Record "Sales Invoice Line";
    begin
        SKU.Reset();
        //Salesinvline.SetRange("No.", ;
        //Salesinvline.SetRange("Location Code", sku."Location Code");
        salesinvline.setrange(type, salesinvline.type::Item);
        Salesinvline.SetFilter("TP Unit Cost_New", '=%1', 0);
        //Salesinvline.SETFILTER("Posting Date", '01/10/25..31/10/25');  // Filter on the records to update only october month lines
        if SalesinvLine.FindSet() then
            repeat
                SKU.Reset();
                SKU.SetRange("Item No.", SalesinvLine."No.");
                SKU.SetRange("Location Code", SalesinvLine."Location Code");
                if SKU.FindFirst() then
                    SalesinvLine."TP Unit Cost_New" := SKU."TP Unit Cost_New"
                else
                    SalesinvLine."TP Unit Cost_New" := 0;
                //SalesinvLine."TP Unit Cost_New" := SKU."TP Unit Cost_New";
                SalesinvLine.Modify();
            until SalesinvLine.Next() = 0;

    end;

    procedure UpdateAllSalespersonCode()
    var

        Salesinvline: Record "Sales Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Reset();
        Salesinvline.SetRange("Salesperson Code", '');
        if Salesinvline.FindSet() then
            repeat
                SalesInvoiceHeader.SetRange("No.", SalesinvLine."Document No.");
                if SalesInvoiceHeader.FindFirst() then begin
                    SalesinvLine."Salesperson Code" := SalesInvoiceHeader."Salesperson Code";
                    SalesinvLine.Modify();
                end;
            until SalesinvLine.Next() = 0;


    end;


    // [EventSubscriber(ObjectType::Codeunit, codeunit::"Sales-Post", OnAfterInsertPostedHeaders, '', true, true)]
    // local procedure OnAfterInsertPostedHeaders(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHdr: Record "Sales Cr.Memo Header"; var ReceiptHeader: Record "Return Receipt Header"; var GenJournalDocumentType: Enum "Gen. Journal Document Type"; var GenJnlLineDocNo: Code[20]; var GenJnlLineExtDocNo: Code[35])




    [EventSubscriber(ObjectType::Codeunit, codeunit::"WMS Management", OnInitWhseJnlLineCopyFromItemJnlLine, '', true, true)]
    procedure OnInitWhseJnlLineCopyFromItemJnlLine(var WarehouseJournalLine: Record "Warehouse Journal Line"; ItemJournalLine: Record "Item Journal Line")
    begin
        WarehouseJournalLine.Narrative := ItemJournalLine.Narrative;
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Whse. Jnl.-Register Line", OnInitWhseEntryCopyFromWhseJnlLine, '', true, true)]
    procedure OnInitWhseEntryCopyFromWhseJnlLine(var WarehouseEntry: Record "Warehouse Entry"; var WarehouseJournalLine: Record "Warehouse Journal Line"; OnMovement: Boolean; Sign: Integer; Location: Record Location; BinCode: Code[20]; var IsHandled: Boolean)
    begin
        WarehouseEntry.Narrative := WarehouseJournalLine.Narrative;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforePostItemJnlLine, '', true, true)]
    local procedure OnBeforePostItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
    var
        Texttrim: text;
    begin
        if (ItemJournalLine."Source Code" = 'RECLASSJNL') and (ItemJournalLine."Journal Template Name" = 'TRANSFER') and
        ((ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Transfer)) then begin

            Texttrim := ItemJournalLine.Narrative;
            ItemJournalLine.TestField(Narrative);
            if StrLen(Texttrim.trim) <> StrLen(ItemJournalLine.Narrative) then
                Error(('Narratives cannot end with empty spaces'));
            if StrLen(Texttrim.trim) < 5 then
                Error('Mandatory Narrative must be completed for Item Journal');
        end;

    end;

    procedure UpdateallMA()

    var
        SCM: Record "Sales Cr.Memo Header";
        SCL: Record "Sales Cr.Memo Line";
        TotalCost: Decimal;
    begin
        SCM.SetRange("Margin Amount", 0);
        if SCM.Findfirst() then
            repeat
                Clear(TotalCost);
                SCL.SetRange("Document No.", SCM."No.");
                if SCL.Findfirst() then
                    repeat
                        TotalCost += SCL."Unit Cost (LCY)" * SCL."Quantity";
                    until SCL.Next() = 0;

                SCM.CalcFields(Amount);
                SCM."Margin Amount" := SCM.Amount - TotalCost;
                SCM."W Margin Amount" := SCM."Margin Amount";
                SCM."Total Cost" := TotalCost;
                SCM."W Total Cost" := SCM."Total Cost";

                if SCM.Amount <> 0 then
                    SCM."Margin %" := (SCM."Margin Amount" / SCM.Amount) * 100;
                scm."W Margin %" := scm."Margin %";
                SCM.Modify();
            until SCM.Next() = 0;

    end;

    procedure UpdateAllIMA();
    var
        SIH: Record "Sales Invoice Header";
        SIL: Record "Sales Invoice Line";
        TotalCost: Decimal;
    begin
        //SIH.SetRange("Posting Date", DMY2Date(1, 10, 2025), DMY2Date(31, 10, 2025)); // Filter on the records to update only october,2025 month invoices
        SIH.SetRange("Margin Amount_New", 0);
        if SIH.Findfirst() then
            repeat
                Clear(TotalCost);
                SIL.SetRange("Document No.", SIH."No.");
                if SIL.Findfirst() then
                    repeat
                        TotalCost += SIL."TP Unit Cost_New" * SIL.Quantity;
                    until SIL.Next() = 0;

                SIH.CalcFields(Amount, "Amount");
                SIH."Margin Amount_New" := SIH."Amount" - TotalCost;
                SIH."Total Cost_New" := TotalCost;
                if SIH."Amount" <> 0 then
                    SIH."Margin %_New" := (SIH."Margin Amount_New" / SIH."Amount") * 100;
                SIH.Modify();
            until SIH.Next() = 0;
        SIH.SetRange("Margin Amount_New", 0);
    end;

    procedure UpdateAllCLEMA();
    var
        CLE: Record "Cust. Ledger Entry";
        SCH: Record "Sales Cr.Memo Header";
    begin
        CLE.Reset();
        cle.SetRange("Document Type", cle."Document Type"::"Credit Memo");
        CLE.SetRange("TP Cr Margin Amount", 0);
        if CLE.Findfirst() then
            repeat
                if SCH.GET(CLE."Document No.") then begin
                    CLE."TP Cr Margin Amount" := SCH."Margin Amount";
                    CLE.MODIFY();
                end;
            until CLE.NEXT() = 0;
    end;


    procedure UpdateAllCLEIMA_New();
    var


        CLE: Record "Cust. Ledger Entry";
        SIH: Record "Sales Invoice Header";
    begin
        CLE.Reset();
        CLE.SetRange("Document Type", CLE."Document Type"::Invoice);
        // CLE.SetRange("Posting Date", DMY2Date(1, 10, 2025), DMY2Date(31, 10, 2025)); // Filter on the records to update only october,2025 month invoices
        CLE.SetRange("Inv Margin Amount_New", 0);
        if CLE.FindFirst() then
            repeat
                if SIH.GET(CLE."Document No.") then begin
                    CLE."Inv Margin Amount_New" := SIH."Margin Amount_New";
                    CLE.MODIFY();
                end;
            until CLE.NEXT() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnValidateSellToCustomerNoOnBeforeRecallModifyAddressNotification, '', false, false)]
    local procedure OnValidateSellToCustomerNoOnBeforeRecallModifyAddressNotification(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")

    var

        Customer: Record Customer;
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then
            if Customer.GET(SalesHeader."Sell-to Customer No.") then begin

                SalesHeader."Customer Grading" := Customer."Customer Grade";
                //SalesHeader.MODIFY;

            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterGetNoSeriesCode, '', false, false)]

    local procedure OnAfterGetNoSeriesCode(var SalesHeader: Record "Sales Header"; SalesReceivablesSetup: Record "Sales & Receivables Setup"; var NoSeriesCode: Code[20])
    begin
        //Overriding the No. Series code for sales quotes to differentiate from sales orders for better reporting and analysis
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then
            if SalesHeader.Master = true then
                NoSeriesCode := SalesReceivablesSetup."Master Sales Quote Nos";
    end;

    procedure UpdateAllCustomerGrading()
    var
        SH: Record "Sales Header";

        Cust: Record Customer;
    begin
        SH.Reset();

        SH.SetRange("Customer Grading", '');
        SH.setrange(SH."Document Type", SH."Document Type"::Quote);
        if SH.Findfirst() then
            repeat
                if Cust.Get(SH."Sell-to Customer No.") then begin
                    SH."Customer Grading" := Cust."Customer Grade";
                    SH.Modify();
                end;
            until SH.Next() = 0;

    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Avail. by Location Lines", OnAfterSetItemFilter, '', false, false)]
    procedure OnAfterSetItemFilter(var Item: Record Item; var PeriodStart: Date; var PeriodEnd: Date);
    begin
        Item.Setrange("Drop Shipment Filter");
    end;

    procedure DrillDownCalcOverdueSalesInvoiceAmount()
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        CustLedgerEntry: Record "Cust. Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // OnBeforeDrillDownCalcOverdueSalesInvoiceAmount(CustLedgerEntry, IsHandled);
        if IsHandled then
            exit;

        SetFilterOverdueSalesInvoice(CustLedgerEntry, false);
        CustLedgerEntry.SetFilter("Remaining Amt. (LCY)", '<>0');
        CustLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        CustLedgerEntry.Ascending := false;

        PAGE.Run(PAGE::"Customer Ledger Entries", CustLedgerEntry);
    end;


    procedure SetFilterOverdueSalesInvoice(var CustLedgerEntry: Record "Cust. Ledger Entry"; CalledFromWebService: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        //  OnBeforeSetFilterOverdueSalesInvoice(CustLedgerEntry, CalledFromWebService, IsHandled);
        if IsHandled then
            exit;

        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, true);
        if CalledFromWebService then
            CustLedgerEntry.SetFilter("Due Date", '<%1', Today)
        else
            CustLedgerEntry.SetFilter("Due Date", '<%1', GetDefaultWorkDate());
    end;

    local procedure GetDefaultWorkDate(): Date
    var
        LogInManagement: Codeunit LogInManagement;
        defaultWorkDate: Date;
    begin
        if DefaultWorkDate = 0D then
            DefaultWorkDate := LogInManagement.GetDefaultWorkDate();
        exit(DefaultWorkDate);
    end;


    procedure GetAmountFormat(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.GetAmountFormatLCYWithUserLocale());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInsertEvent', '', true, true)]

    local procedure OnAfterInsertEvent1(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if Rec."Ship-to Address" <> Rec."Sell-to Address" then  //Commented beacause of Shipping state vs Warehouse Location logic is enough and working fine - Tommy
            Rec."Alt Address" := 'Alternative Address'
        else
            Rec."Alt Address" := '';
        Rec.Modify();


    end;

    procedure UpdateExternalDocNo()       // #290 Posted Sales Invoice Lines - External Document No. field update from Sales Invoice Header
    var
        SIH: Record "Sales Invoice Header";
        SIL: Record "Sales Invoice Line";
    begin
        SIL.Reset();
        SIL.SetRange("External Document No.", '');
        if SIL.FindSet() then
            repeat
                if SIH.Get(SIL."Document No.") then begin
                    SIL."External Document No." := SIH."External Document No.";
                    SIL.Modify();
                end;
            until SIL.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Templ. Mgt.", OnApplyItemTemplateOnBeforeItemGet, '', false, false)]
    local procedure OnApplyItemTemplateOnBeforeItemGet(var Item: Record Item; ItemTempl: Record "Item Templ."; UpdateExistingValues: Boolean)
    var
        ExtTextheader: Record "Extended Text Header";
        ExtTextLine: Record "Extended Text Line";
        ExtTextheader1: Record "Extended Text Header";
        ExtTextLine1: Record "Extended Text Line";
    begin
        ExtTextheader.Reset();
        ExtTextheader.SetRange(ExtTextheader."Table Name", ExtTextheader."Table Name"::"Item Templ.");
        ExtTextheader.SetRange("No.", ItemTempl.Code);
        if ExtTextheader.FindFirst() then begin
            ExtTextheader1.Init();
            ExtTextheader1 := ExtTextheader;
            ExtTextheader1."Table Name" := ExtTextheader1."Table Name"::Item;
            ExtTextheader1."No." := Item."No.";
            ExtTextheader1.Insert(true);

            ExtTextLine.SetRange("Table Name", ExtTextLine."Table Name"::"Item Templ.");
            ExtTextLine.SetRange("No.", ItemTempl.Code);
            if ExtTextLine.FindFirst() then begin
                repeat
                    ExtTextLine1.Init();
                    ExtTextLine1 := ExtTextLine;
                    ExtTextLine1."Table Name" := ExtTextLine1."Table Name"::Item;
                    ExtTextLine1."No." := Item."No.";
                    ExtTextLine1.Insert(true);
                until ExtTextLine.Next() = 0;
            end;
        end;

    end; // #275: Item Template- Extended Text. Need to uncomment and deploy upon Justin's confirmation

    procedure UpdatedEmailSent()    // To make Emial sent field true for all sales invoices those are false to turn on job queue for sending emails
    var
        SIH: Record "Sales Invoice Header";
    begin
        SIH.Reset();
        SIH.SetRange("WTPL Email Sent", false);
        if SIH.FindFirst() then
            repeat
                SIH."WTPL Email Sent" := true;
                SIH.Modify();
            until SIH.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforePerformManualReleaseProcedure, '', false, false)]
    local procedure OnBeforePerformManualReleaseProcedure(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    var
        // QstnLbl: Text;

        Warining: Text;
        Question: Text;
        SalesSetup: Record "Sales & Receivables Setup";

        Loc2: Text[2];
        State2: Text[2];
        Text001: Label 'The order amount is less than %1. Would you like to proceed?';
    begin


        if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then begin


            if SalesHeader."Quote Type" = SalesHeader."Quote Type"::" " then
                Error('Please select Quote Type before releasing the Quote');


        end;// Support ticket from outlook from Justin, need to uncomment and deploy upon Justin's confirmation

        Loc2 := CopyStr(SalesHeader."Location Code", 1, 2);
        State2 := CopyStr(SalesHeader."Ship-to County", 1, 2);
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            if Loc2 <> State2 then begin
                if not Confirm('The Location Code is different from Shipping state. Do you want to continue?') then
                    IsHandled := true;
            end;
        end;
        Question := Text001;
        SalesSetup.Get();
        SalesHeader.CalcFields(Amount);
        IF SalesHeader.Amount < SalesSetup."Minimum Order Amount" then begin
            IF Not Confirm(Question, False, SalesSetup."Minimum Order Amount") then
                Error('This process is cancelled by User!');
        end;


    end;

    procedure CalcGrosMarginLast12Months(CustomerNo: Code[20]): Decimal
    var
        CLE: Record "Cust. Ledger Entry";
        customer: Record Customer;
        FromDate: Date;
        ToDate: Date;
        GrossMargin: Decimal;
    begin
        ToDate := Today();
        FromDate := CalcDate('<-12M', ToDate);
        CLE.Reset();
        CLE.SetRange("Sell-to Customer No.", customer."No.");
        CLE.SetRange("Document Type", CLE."Document Type"::Invoice);
        CLE.SetFilter("Posting Date", '%1..%2', FromDate, ToDate);
        if CLE.FindSet() then
            repeat
                GrossMargin += CLE."Inv Margin Amount_New";
            until CLE.Next() = 0;
        customer.Get(CLE."Sell-to Customer No.");
        if customer.FindFirst() then
            customer.Marginamount_12months := GrossMargin;
    end;

    procedure updateitemcategorygroup()
    var
        Item: Record Item;
        SIL: Record "Sales Invoice Line";
    begin
        SIL.Reset();
        SIL.SetRange(Type, SIL.Type::Item);
        if SIL.FindSet() then
            repeat
                if Item.Get(SIL."No.") then begin
                    SIL."Item Category Group" := Item."Item Category Group";
                    SIL.Modify();
                end;
            until SIL.Next() = 0;
    end;

    procedure UpdateItemsBlocked()
    var
        Item: Record Item;
        SIL: Record "Sales Invoice Line";
    begin
        SIL.Reset();
        SIL.SetRange(Type, SIL.Type::Item);
        if SIL.FindSet() then
            repeat
                if Item.Get(SIL."No.") then begin
                    SIL.Blocked_Item := Item."Blocked";
                    SIL.Modify();
                end;
            until SIL.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterSalesLineModify(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var

        NewBackorderQty: Decimal;

    begin



        if Rec."Qty. Shipped (Base)" <> 0 then begin

            NewBackorderQty := Rec."Quantity" - Rec."Qty. Shipped (Base)";

            if Rec."Backorder Quantity" <> NewBackorderQty then begin
                Rec.Validate("Backorder Quantity", NewBackorderQty);
                Rec.Modify();
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Page, Page::"Sales Quote", OnQueryClosePageEvent, '', false, false)]
    local procedure OnClosePageEvent(var Rec: Record "Sales Header"; var AllowClose: Boolean)
    begin


        if Rec."Document Type" = Rec."Document Type"::Quote then
            if Rec."Quote Type" = Rec."Quote Type"::" " then
                //Error('Please select Quote Type before closing the Sales Quote');
         if not Confirm('Please select Quote Type before closing the Sales Quote. Do you want to exit anyway?', false) then
                    AllowClose := false; // Stay on the page if No



    end;


    [EventSubscriber(ObjectType::Page, Page::"Master Sales Quote", OnQueryClosePageEvent, '', false, false)]
    local procedure onclosepageevent1(var Rec: Record "Sales Header"; var AllowClose: Boolean)
    begin
        if Rec."Document Type" = Rec."Document Type"::Quote then
            if Rec."Quote Type" = Rec."Quote Type"::" " then
                if not Confirm('Please select Quote Type before closing the Sales Quote. Do you want to exit anyway?', false) then
                    AllowClose := false; // Stay on the page if No
    end;


    [EventSubscriber(ObjectType::Page, Page::"Customer Card", OnAfterOnOpenPage, '', false, false)]// Balance and Credit limit warning on customer card - Tommy
    local procedure OnAfterOnOpenPage(var Customer: Record Customer)
    begin


        if (CopyStr(Customer.Name, 1, 17) = 'KONNECT FASTENING') or
           (CopyStr(Customer.Name, 1, 3) = 'CFS') then begin
            Message('Please do not contact for payment. Invoices are manually consolidated monthly.');   //A pop up message when a customer card is clicked - Tommy
        end;
        Customer.CalcFields(Balance);
        if (Customer."Balance" >= Customer."Credit Limit (LCY)") and (Customer."Credit Limit (LCY)" > 0) then begin
            Message('Warning: Customer %1 has reached or exceeded the credit limit!', Customer."No.");
        end;
        if (CopyStr(Customer."Customer Price Group", 1, 3) = 'SBG') then begin
            Message('This is Part of SYNERGY BUYERS GROUP');
        end;


    end;




    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, 'Sell-to Customer No.', false, false)]  // Balance and Credit limit warning on sales order- Tommy
    local procedure OnAfterValidateSellToCustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if Rec."Sell-to Customer No." <> '' then
            if Customer.Get(Rec."Sell-to Customer No.") then
                Customer.CalcFields(Balance);
        if (Customer."Balance" >= Customer."Credit Limit (LCY)") and (Customer."Credit Limit (LCY)" > 0) then
            Message('Warning: Customer %1 has reached or exceeded the credit limit!', Customer."No.");
    end;

    procedure UpdateOrderlineNo(PurchRcptDocNo: Code[20]; PurchRcptLineNo: Integer)
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";

        dlg: Dialog;
        OrderLineNo: Integer;
    begin

        // dlg.Open('Enter Order Line No.:\#1########', OrderLineNo);

        PurchRcptLine.SetRange("Document No.", 'PR-003251');                     // To Update Order line no. for the document asked by Lorina
        PurchRcptLine.SetRange("Line No.", 10000);
        if PurchRcptLine.FindFirst() then begin
            PurchRcptLine."Order Line No." := 10000;
            PurchRcptLine.Modify();
            Message('Order Line No. %1 is updated for Purchase Receipt Line %2', OrderLineNo, PurchRcptLineNo);
        end else
            Message('Th e Purchase Receipt Line %1 for document %2 is not found', PurchRcptLineNo, PurchRcptDocNo);
    end;




    procedure UpdateYourReference()  // Copying Your Reference from sales order to posted wshe shipments for web services API
    var
        SH: Record "Sales Header";
        PWSH: Record "Posted Whse. Shipment Header";
    begin
        SH.SetRange("Document Type", SH."Document Type"::Order);

        if SH.FindSet() then
            repeat
                PWSH.Reset();
                PWSH.SetRange("Order No.", SH."No.");

                if PWSH.FindSet() then
                    repeat

                        PWSH."Your Reference" := SH."Your Reference";

                        if CopyStr(PWSH."Your Reference", 1, 3) = 'WEB' then
                            PWSH."Web Order No." := CopyStr(PWSH."Your Reference", 4)  // Web order number from sales order for web services
                        else
                            PWSH."Web Order No." := '';

                        PWSH.Modify(true);

                    until PWSH.Next() = 0;

            until SH.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ArchiveManagement", OnAfterSalesHeaderArchiveInsert, '', false, false)]
    local procedure OnAfterSalesHeaderArchiveInsert(var SalesHeaderArchive: Record "Sales Header Archive"; SalesHeader: Record "Sales Header")

    begin

        SalesHeaderArchive.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order");
        SalesHeaderArchive.SetRange("No.", SalesHeader."No.");
        if SalesHeaderArchive.FindSet() then
            repeat
                SalesHeaderArchive.CreatedBy := SalesHeader."Created By";
                SalesHeaderArchive.Modify();
            until SalesHeaderArchive.Next() = 0;



    end;




    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnUpdateShipToAddressOnAfterCopyFromLocation, '', false, false)]
    local procedure OnUpdateShipToAddressOnAfterCopyFromLocation(var PurchaseHeader: Record "Purchase Header"; Location: Record Location)
    var

    begin

        PurchaseHeader."Receiving Address" := Location."Receiving Address";
        PurchaseHeader."Receiving City" := Location."Receiving City";
        PurchaseHeader."Receiving Post Code" := Location."Receiving Post Code";
        PurchaseHeader."Receiving County" := Location."Receiving County";
        PurchaseHeader."Receiving Country/Region Code" := Location."Receiving Country/Region Code";
        PurchaseHeader."ReceivingPhone No." := Location."ReceivingPhone No.";

    end;


    // [EventSubscriber(ObjectType::Page, Page::"Purchase Order", OnBeforeValidateShippingOption, '', false, false)]


    // local procedure OnBeforeValidateShippingOption(var PurchaseHeader: Record "Purchase Header"; ShipToOptions: Option "Default (Company Address)",Location,"Customer Address","Custom Address"; var IsHandled: Boolean)
    // var
    //     Location: Record Location;
    // begin
    //     if ShipToOptions = ShipToOptions::"Customer Address" then begin

    //         PurchaseHeader."Receiving Address" := purchaseHeader."Ship-to Address";
    //         PurchaseHeader."Receiving Address2" := purchaseHeader."Ship-to Address 2";
    //         PurchaseHeader."Receiving City" := purchaseHeader."Ship-to City";
    //         PurchaseHeader."Receiving Post Code" := purchaseHeader."Ship-to Post Code";
    //         PurchaseHeader."Receiving County" := purchaseHeader."Ship-to County";
    //         PurchaseHeader."Receiving Country/Region Code" := purchaseHeader."Ship-to Country/Region Code";
    //         PurchaseHeader."ReceivingPhone No." := purchaseHeader."Ship-to Phone No.";
    //     end;
    // end;

    //[EventSubscriber(ObjectType::Page, Page::"Purchase Order", OnAfterCalculateCurrentShippingAndPayToOption, '', false, false)]

    //  [IntegrationEvent(false, false)]
    // local procedure OnAfterCalculateCurrentShippingAndPayToOption(var ShipToOptions: Option "Default (Company Address)",Location,"Customer Address","Custom Address"; var PayToOptions: Option "Default (Vendor)","Another Vendor","Custom Address"; PurchaseHeader: Record "Purchase Header")
    // begin
    //      if ShipToOptions = ShipToOptions::"Customer Address" then begin

    //         PurchaseHeader."Receiving Address" := purchaseHeader."Ship-to Address";
    //         PurchaseHeader."Receiving Address2" := purchaseHeader."Ship-to Address 2";
    //         PurchaseHeader."Receiving City" := purchaseHeader."Ship-to City";
    //         PurchaseHeader."Receiving Post Code" := purchaseHeader."Ship-to Post Code";
    //         PurchaseHeader."Receiving County" := purchaseHeader."Ship-to County";
    //         PurchaseHeader."Receiving Country/Region Code" := purchaseHeader."Ship-to Country/Region Code";
    //         PurchaseHeader."ReceivingPhone No." := purchaseHeader."Ship-to Phone No.";
    //     end;
    // end;



}


