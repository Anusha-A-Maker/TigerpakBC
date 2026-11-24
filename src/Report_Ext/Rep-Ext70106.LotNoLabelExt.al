namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using System.Text;
using System.Utilities;

reportextension 70106 "Lot No Label Ext" extends "Lot No Label"
{
    dataset
    {
        addlast("Lot No. Information")
        {
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);

                column(CopyNumber; Number)
                {
                }
                column(CopyDescription; CopyDescription)
                {
                }
                column(CopyItemNo; "Lot No. Information"."Item No.")
                {
                }
                column(CopyVariantCode; "Lot No. Information"."Variant Code")
                {
                }
                column(CopyLotNo; CopyLotNo)
                {
                }
                column(CopyLotNo2D; CopyLotNo2D)
                {
                }

                trigger OnAfterGetRecord()
                var
                    Item: Record Item;
                    BarcodeString: Text;
                    BarcodeFontProvider: Interface "Barcode Font Provider";
                    BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
                begin
                    Item.SetLoadFields(Item.Description);
                    Item.Get("Lot No. Information"."Item No.");
                    CopyDescription := Item.Description;

                    Clear(CopyLotNo);
                    Clear(CopyLotNo2D);
                    if "Lot No. Information"."Lot No." = '' then
                        exit;

                    BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                    BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
                    BarcodeString := "Lot No. Information"."Lot No.";
                    BarcodeFontProvider.ValidateInput(BarcodeString, CopyBarcodeSymbology);
                    CopyLotNo := BarcodeFontProvider.EncodeFont(BarcodeString, CopyBarcodeSymbology);
                    CopyLotNo2D := BarcodeFontProvider2D.EncodeFont(BarcodeString, CopyBarcodeSymbology2D);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, NumberOfCopies);
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            addlast(Content)
            {
                group(CopyOptions)
                {
                    Caption = 'Options';

                    field(NumberOfCopies; NumberOfCopies)
                    {
                        ApplicationArea = All;
                        Caption = 'No. of Copies';
                        MinValue = 1;
                        ToolTip = 'Specifies the number of copies to print for each selected lot number.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if NumberOfCopies <= 0 then
                NumberOfCopies := 1;
        end;
    }
    var
        CopyBarcodeSymbology: Enum "Barcode Symbology";
        CopyBarcodeSymbology2D: Enum "Barcode Symbology 2D";
        CopyDescription: Text[100];
        CopyLotNo: Text;
        CopyLotNo2D: Text;
        NumberOfCopies: Integer;

    trigger OnPreReport()
    begin
        if NumberOfCopies <= 0 then
            NumberOfCopies := 1;
        CopyBarcodeSymbology := Enum::"Barcode Symbology"::Code39;
        CopyBarcodeSymbology2D := Enum::"Barcode Symbology 2D"::"QR-Code";
    end;
}
