namespace TigerpakBC.TigerpakBC;
using Microsoft.Sales.Customer;

reportextension 70104 "Tax - Invoice Ext" extends "Tax - Invoice"
{
    dataset
    {
        add(Header)
        {
            column(XmasTradingHours; XmasTradingHours)
            {

            }

            column(BillToName; "Bill-to Name") { }

            column(BillToAddress; "Bill-to Address") { }
            column(BillToAddress2; "Bill-to Address 2") { }
            column(BillToCity; "Bill-to City") { }
            column(BillToPostCode; "Bill-to Post Code") { }
            column(BillToCountryRegionCode; "Bill-to Country/Region Code") { }
            column(BillToCounty; "Bill-to County") { }
            column(BillToContact; "Bill-to Contact") { }


        }
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            begin

                if Customer.get(Header."Sell-to Customer No.") then begin
                    if Customer."Xmas Trading Hours" <> '' then
                        XmasTradingHours := 'Xmas Trading Hours: ' + Customer."Xmas Trading Hours"
                    else
                        XmasTradingHours := '';
                end;
            end;
        }

    }
    rendering
    {
        layout(XmasTrading)
        {
            Type = RDLC;
            LayoutFile = './Layouts/XMasTaxInvoice.rdl';
        }
        layout("Taxinvoice_InvoiceTO_Bill-ToAddress")
        {
            Type = RDLC;
            LayoutFile = './Layouts/Taxinvoice_InvoiceTO_Bill-ToAddress.rdl';
        }
    }
    var
        XmasTradingHours: Text[100];
        Customer: Record Customer;
}

