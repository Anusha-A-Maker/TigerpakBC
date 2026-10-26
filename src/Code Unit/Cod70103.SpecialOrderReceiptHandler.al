namespace TigerpakBC.TigerpakBC;

using Microsoft.Purchases.History;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Tracking;

codeunit 70103 "Special Order Receipt Handler"
{
    // Shares the scoped quantity-validation context with the association-check subscriber.
    SingleInstance = true;

    // [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Line", OnAfterInsertEvent, '', false, false)]
    //   local procedure OnAfterInsertPurchRcptLine(
    //     var Rec: Record "Purch. Rcpt. Line";
    //     RunTrigger: Boolean)
    //   var
    //     PurchaseLine: Record "Purchase Line";
    //     PurchRcptLine: Record "Purch. Rcpt. Line";
    //     SalesLine: Record "Sales Line";
    //     TotalOverReceiptBase: Decimal;
    //     AlreadyAppliedBase: Decimal;
    //     QtyPerUnitOfMeasure: Decimal;
    //     QtyPerUnitOfMeasureErr: Label 'Cannot update the linked sales line because its Qty. per Unit of Measure is zero.', Comment = 'Raised when the linked sales line has an invalid unit conversion.';
    //   begin
    //     if (Rec."Special Order Sales No." = '') or
    //        (Rec."Special Order Sales Line No." = 0)
    //     then
    //       exit;

    //     PurchaseLine.SetLoadFields("Special Order", "Quantity (Base)");
    //     if not PurchaseLine.Get(
    //       PurchaseLine."Document Type"::Order,
    //       Rec."Order No.",
    //       Rec."Order Line No.")
    //     then
    //       exit;

    //     if not PurchaseLine."Special Order" then
    //       exit;

    //     SalesLine.SetLoadFields(Quantity, "Qty. per Unit of Measure");
    //     if not SalesLine.Get(
    //       SalesLine."Document Type"::Order,
    //       Rec."Special Order Sales No.",
    //       Rec."Special Order Sales Line No.")
    //     then
    //       exit;

    //     PurchRcptLine.SetRange("Order No.", Rec."Order No.");
    //     PurchRcptLine.SetRange("Order Line No.", Rec."Order Line No.");
    //     PurchRcptLine.CalcSums("Quantity (Base)");

    //     TotalOverReceiptBase :=
    //       PurchRcptLine."Quantity (Base)" - PurchaseLine."Quantity (Base)";
    //     if TotalOverReceiptBase <= 0 then
    //       exit;

    //     QtyPerUnitOfMeasure := SalesLine."Qty. per Unit of Measure";
    //     if QtyPerUnitOfMeasure = 0 then
    //       Error(QtyPerUnitOfMeasureErr);

    //     // Special-order creation normally makes the original sales and purchase
    //     // quantities equivalent in base units. Use that as the baseline to avoid
    //     // adding the same over-receipt again on later receipt postings.
    //     AlreadyAppliedBase :=
    //       (SalesLine.Quantity * QtyPerUnitOfMeasure) -
    //       PurchaseLine."Quantity (Base)";
    //     if AlreadyAppliedBase < 0 then
    //       AlreadyAppliedBase := 0;

    //     if TotalOverReceiptBase <= AlreadyAppliedBase then
    //       exit;

    //     SalesLine.Validate(
    //       Quantity,
    //       SalesLine.Quantity +
    //       ((TotalOverReceiptBase - AlreadyAppliedBase) / QtyPerUnitOfMeasure));
    //     SalesLine.Modify(true);
    //   end;



    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Over-Receipt Quantity', false, false)]
    local procedure OnAfterValidateOverReceiptQty(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Delta: Decimal;
    begin
        if Rec.IsTemporary() then
            exit;
        if (Rec."Document Type" <> Rec."Document Type"::Order) or (Rec.Type <> Rec.Type::Item) then
            exit;

        Delta := Rec."Over-Receipt Quantity" - xRec."Over-Receipt Quantity";
        if Delta = 0 then
            exit;

        // Convert purchase base qty to sales line UoM later; work in base here
        UpdateLinkedSalesLine(Rec, Delta * Rec."Qty. per Unit of Measure");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeCheckAssocPurchOrder', '', false, false)]
    local procedure OnBeforeCheckAssocPurchOrder(var SalesLine: Record "Sales Line"; TheFieldCaption: Text[250]; var IsHandled: Boolean; xSalesLine: Record "Sales Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if not IsApplyingOverReceiptQuantity then
            exit;
        if IsHandled or (TheFieldCaption <> SalesLine.FieldCaption(Quantity)) then
            exit;
        if (SalesLine."Document Type" <> OverReceiptSalesDocumentType) or
           (SalesLine."Document No." <> OverReceiptSalesDocumentNo) or
           (SalesLine."Line No." <> OverReceiptSalesLineNo) or
           (SalesLine.Quantity <> OverReceiptTargetQuantity) or
           (xSalesLine.Quantity = SalesLine.Quantity) or
           (SalesLine."Special Order Purchase No." <> OverReceiptPurchaseDocumentNo) or
           (SalesLine."Special Order Purch. Line No." <> OverReceiptPurchaseLineNo)
        then
            exit;

        PurchaseLine.SetLoadFields("Special Order", "Special Order Sales No.", "Special Order Sales Line No.");
        if not PurchaseLine.Get(PurchaseLine."Document Type"::Order, OverReceiptPurchaseDocumentNo, OverReceiptPurchaseLineNo) then
            exit;
        if not PurchaseLine."Special Order" or
           (PurchaseLine."Special Order Sales No." <> SalesLine."Document No.") or
           (PurchaseLine."Special Order Sales Line No." <> SalesLine."Line No.")
        then
            exit;

        IsHandled := true;
    end;

    local procedure UpdateLinkedSalesLine(PurchLine: Record "Purchase Line"; DeltaBase: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        if not FindLinkedSalesLine(PurchLine, SalesLine) then
            exit;

        ApplyDelta(PurchLine, SalesLine, DeltaBase);
    end;

    local procedure FindLinkedSalesLine(PurchLine: Record "Purchase Line"; var SalesLine: Record "Sales Line"): Boolean
    var
        ResEntry: Record "Reservation Entry";
        PairedEntry: Record "Reservation Entry";
    begin
        // 1. Special Order link
        if PurchLine."Special Order" and (PurchLine."Special Order Sales No." <> '') then
            exit(SalesLine.Get(SalesLine."Document Type"::Order,
                               PurchLine."Special Order Sales No.",
                               PurchLine."Special Order Sales Line No."));

        // 2. Reservation / order-to-order binding
        ResEntry.SetRange("Source Type", Database::"Purchase Line");
        ResEntry.SetRange("Source Subtype", PurchLine."Document Type".AsInteger());
        ResEntry.SetRange("Source ID", PurchLine."Document No.");
        ResEntry.SetRange("Source Ref. No.", PurchLine."Line No.");
        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Reservation);
        ResEntry.SetRange(Positive, true);
        if ResEntry.FindSet() then
            repeat
                if PairedEntry.Get(ResEntry."Entry No.", false) then
                    if (PairedEntry."Source Type" = Database::"Sales Line") and
                       (PairedEntry."Source Subtype" = SalesLine."Document Type"::Order.AsInteger())
                    then
                        exit(SalesLine.Get(SalesLine."Document Type"::Order,
                                           PairedEntry."Source ID",
                                           PairedEntry."Source Ref. No."));
            until ResEntry.Next() = 0;

        exit(false);
    end;

    local procedure ApplyDelta(PurchLine: Record "Purchase Line"; var SalesLine: Record "Sales Line"; DeltaBase: Decimal)
    var
        NewQty: Decimal;
        DeltaSalesUoM: Decimal;
    begin
        if SalesLine."Qty. per Unit of Measure" = 0 then
            SalesLine."Qty. per Unit of Measure" := 1;
        DeltaSalesUoM := DeltaBase / SalesLine."Qty. per Unit of Measure";

        NewQty := SalesLine.Quantity + DeltaSalesUoM;
        // Never reduce below what has already been shipped
        if NewQty < SalesLine."Quantity Shipped" then
            NewQty := SalesLine."Quantity Shipped";
        if NewQty = SalesLine.Quantity then
            exit;

        SalesLine.SuspendStatusCheck(true); // allows change on a Released order - review vs. your approval process
        if (SalesLine."Special Order Purch. Line No." <> 0) and
           (SalesLine."Special Order Purchase No." = PurchLine."Document No.") and
           (SalesLine."Special Order Purch. Line No." = PurchLine."Line No.")
        then begin
            IsApplyingOverReceiptQuantity := true;
            OverReceiptSalesDocumentType := SalesLine."Document Type";
            OverReceiptSalesDocumentNo := SalesLine."Document No.";
            OverReceiptSalesLineNo := SalesLine."Line No.";
            OverReceiptPurchaseDocumentNo := PurchLine."Document No.";
            OverReceiptPurchaseLineNo := PurchLine."Line No.";
            OverReceiptTargetQuantity := NewQty;

            if not TryValidateSalesLineQuantity(SalesLine, NewQty) then begin
                ClearOverReceiptQuantityContext();
                Error(OverReceiptQuantityUpdateErr, GetLastErrorText());
            end;

            ClearOverReceiptQuantityContext();
        end else
            SalesLine.Validate(Quantity, NewQty);

        SalesLine.Modify(true);
    end;

    [TryFunction]
    local procedure TryValidateSalesLineQuantity(var SalesLine: Record "Sales Line"; NewQty: Decimal)
    begin
        SalesLine.Validate(Quantity, NewQty);
    end;

    local procedure ClearOverReceiptQuantityContext()
    begin
        IsApplyingOverReceiptQuantity := false;
        Clear(OverReceiptSalesDocumentNo);
        Clear(OverReceiptSalesLineNo);
        Clear(OverReceiptPurchaseDocumentNo);
        Clear(OverReceiptPurchaseLineNo);
        Clear(OverReceiptTargetQuantity);
    end;

    var
        IsApplyingOverReceiptQuantity: Boolean;
        OverReceiptSalesDocumentType: Enum "Sales Document Type";
        OverReceiptSalesDocumentNo: Code[20];
        OverReceiptSalesLineNo: Integer;
        OverReceiptPurchaseDocumentNo: Code[20];
        OverReceiptPurchaseLineNo: Integer;
        OverReceiptTargetQuantity: Decimal;
        OverReceiptQuantityUpdateErr: Label 'Could not update the linked sales order quantity. %1', Comment = 'Error raised when applying the over-receipt quantity to the special-order sales line.';


}
