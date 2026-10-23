namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Tracking;

codeunit 70102 "Lot Info Events Handler"
{
    [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertItemLedgerEntry(var Rec: Record "Item Ledger Entry"; RunTrigger: Boolean)
    var
        LotNoInformation: Record "Lot No. Information";
    begin
        if Rec."Lot No." = '' then
            exit;

        if not LotNoInformation.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.") then begin
            LotNoInformation.Init();
            LotNoInformation.Validate("Item No.", Rec."Item No.");
            LotNoInformation.Validate("Variant Code", Rec."Variant Code");
            LotNoInformation.Validate("Lot No.", Rec."Lot No.");
            LotNoInformation."Expiration Date" := Rec."Expiration Date";
            LotNoInformation.Insert(true);
        end;

        if LotNoInformation."Expiration Date" <> Rec."Expiration Date" then begin
            LotNoInformation."Expiration Date" := Rec."Expiration Date";
            LotNoInformation.Modify();
        end;
    end;
}
