namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Item;
using System.Text;
using System.Utilities;

reportextension 70105 "Lot No. Label Word Ext" extends 6628
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
                column(CopyExpirationDate; "Lot No. Information"."Expiration Date")
                {
                }
                column(CopyExpirationDateLabel; ExpirationDateLabel)
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
                    if "Lot No. Information"."Lot No." = '' then begin
                        CurrReport.Skip();
                        exit;
                    end;

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

    rendering
    {
        layout(LotNoLabelCopiesWord)
        {
            Type = Word;
            LayoutFile = './src/Layouts/LotNoLabel6628Copies.docx';
            Caption = 'Lot No. Label - Multiple Copies (Word)';
        }
    }

    var
        CopyBarcodeSymbology: Enum "Barcode Symbology";
        CopyBarcodeSymbology2D: Enum "Barcode Symbology 2D";
        CopyDescription: Text[100];
        CopyLotNo: Text;
        CopyLotNo2D: Text;
        NumberOfCopies: Integer;
        ExpirationDateLabel: Label 'Expiration Date';

    trigger OnPreReport()
    begin
        if NumberOfCopies <= 0 then
            NumberOfCopies := 1;

        CopyBarcodeSymbology := Enum::"Barcode Symbology"::Code39;
        CopyBarcodeSymbology2D := Enum::"Barcode Symbology 2D"::"QR-Code";
    end;
}
