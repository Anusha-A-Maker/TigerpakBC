namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using System.Text;
using System.Utilities;

report 70105 "Lot No Label by Quantity"
{
    ApplicationArea = All;
    Caption = 'Lot No. Label by Quantity';
    UsageCategory = ReportsAndAnalysis;
    WordMergeDataItem = "Lot No. Information";
    DefaultRenderingLayout = LotNoLabelQuantityWord;

    dataset
    {
        dataitem("Lot No. Information"; "Lot No. Information")
        {
            DataItemTableView = sorting("Item No.");
            RequestFilterFields = "Item No.", "Variant Code", "Lot No.";

            column(Quantity; "Quantity")
            {
            }

            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);

                column(CopyNumber; Number)
                {
                }
                column(ItemNo; "Lot No. Information"."Item No.")
                {
                }
                column(Description; ItemDescription)
                {
                }
                column(Variant_Code; "Lot No. Information"."Variant Code")
                {
                }
                column(LotNo; LotNoCode)
                {
                }
                column(LotNo_2D; LotNoQRCode)
                {
                }
                column(Expiration_Date; ExpirationDateLabel)
                {
                }
                column(ExpirationDate; "Lot No. Information"."Expiration Date")
                {
                }

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, NumberOfCopies);
                end;
            }

            trigger OnAfterGetRecord()
            var
                Item: Record Item;
                BarcodeString: Text;
                BarcodeFontProvider: Interface "Barcode Font Provider";
                BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
            begin
                if "Lot No." = '' then
                    CurrReport.Skip();

                if NumberOfCopies <= 0 then
                    CurrReport.Skip();

                BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
                BarcodeSymbology2D := Enum::"Barcode Symbology 2D"::"QR-Code";
                BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;

                Item.SetLoadFields(Item.Description);
                Item.Get("Item No.");
                ItemDescription := Item.Description;

                BarcodeString := "Lot No.";
                BarcodeFontProvider.ValidateInput(BarcodeString, BarcodeSymbology);
                LotNoCode := BarcodeFontProvider.EncodeFont(BarcodeString, BarcodeSymbology);
                LotNoQRCode := BarcodeFontProvider2D.EncodeFont(BarcodeString, BarcodeSymbology2D);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
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
        layout(LotNoLabelQuantityWord)
        {
            Type = Word;
            LayoutFile = './src/Layouts/LotNoLabelQuantity.docx';
            Caption = 'Lot No. Label - Word';
        }
    }

    var
        BarcodeSymbology: Enum "Barcode Symbology";
        BarcodeSymbology2D: Enum "Barcode Symbology 2D";
        ItemDescription: Text[100];
        LotNoCode: Text;
        LotNoQRCode: Text;
        NumberOfCopies: Integer;
        Expiration_Date: Text[30];
        ExpirationDateLabel: Label 'Expiration Date';
}
