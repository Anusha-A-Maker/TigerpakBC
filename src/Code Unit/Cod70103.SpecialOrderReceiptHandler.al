namespace TigerpakBC.TigerpakBC;

using Microsoft.Purchases.History;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

codeunit 70103 "Special Order Receipt Handler"
{
 
[EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Line", OnAfterInsertEvent, '', false, false)]
  local procedure OnAfterInsertPurchRcptLine(
    var Rec: Record "Purch. Rcpt. Line";
    RunTrigger: Boolean)
  var
    PurchaseLine: Record "Purchase Line";
    PurchRcptLine: Record "Purch. Rcpt. Line";
    SalesLine: Record "Sales Line";
    TotalOverReceiptBase: Decimal;
    AlreadyAppliedBase: Decimal;
    QtyPerUnitOfMeasure: Decimal;
    QtyPerUnitOfMeasureErr: Label 'Cannot update the linked sales line because its Qty. per Unit of Measure is zero.', Comment = 'Raised when the linked sales line has an invalid unit conversion.';
  begin
    if (Rec."Special Order Sales No." = '') or
       (Rec."Special Order Sales Line No." = 0)
    then
      exit;

    PurchaseLine.SetLoadFields("Special Order", "Quantity (Base)");
    if not PurchaseLine.Get(
      PurchaseLine."Document Type"::Order,
      Rec."Order No.",
      Rec."Order Line No.")
    then
      exit;

    if not PurchaseLine."Special Order" then
      exit;

    SalesLine.SetLoadFields(Quantity, "Qty. per Unit of Measure");
    if not SalesLine.Get(
      SalesLine."Document Type"::Order,
      Rec."Special Order Sales No.",
      Rec."Special Order Sales Line No.")
    then
      exit;

    PurchRcptLine.SetRange("Order No.", Rec."Order No.");
    PurchRcptLine.SetRange("Order Line No.", Rec."Order Line No.");
    PurchRcptLine.CalcSums("Quantity (Base)");

    TotalOverReceiptBase :=
      PurchRcptLine."Quantity (Base)" - PurchaseLine."Quantity (Base)";
    if TotalOverReceiptBase <= 0 then
      exit;

    QtyPerUnitOfMeasure := SalesLine."Qty. per Unit of Measure";
    if QtyPerUnitOfMeasure = 0 then
      Error(QtyPerUnitOfMeasureErr);

    // Special-order creation normally makes the original sales and purchase
    // quantities equivalent in base units. Use that as the baseline to avoid
    // adding the same over-receipt again on later receipt postings.
    AlreadyAppliedBase :=
      (SalesLine.Quantity * QtyPerUnitOfMeasure) -
      PurchaseLine."Quantity (Base)";
    if AlreadyAppliedBase < 0 then
      AlreadyAppliedBase := 0;

    if TotalOverReceiptBase <= AlreadyAppliedBase then
      exit;

    SalesLine.Validate(
      Quantity,
      SalesLine.Quantity +
      ((TotalOverReceiptBase - AlreadyAppliedBase) / QtyPerUnitOfMeasure));
    SalesLine.Modify(true);
  end;
} 

