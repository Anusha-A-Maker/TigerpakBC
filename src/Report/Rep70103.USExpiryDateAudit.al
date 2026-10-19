
namespace TigerpakBC.TigerpakBC;

using Microsoft.Inventory.Item;

report 70103 "US Expiry Date Audit"
{
  ApplicationArea = All;
  Caption = 'US Expiry Date Audit';
  UsageCategory = ReportsAndAnalysis;
  DefaultRenderingLayout = USExpiryDateAudit;

  dataset
  {
    dataitem(Item; Item)
    {
      DataItemTableView = sorting("No.");
      RequestFilterFields = "No.";

      column(ItemNo; "No.")
      {
        Caption = 'Item No.';
      }
      column(Description; Description)
      {
        Caption = 'Description';
      }
      column(USExpiryDate; "US-Expiry Date")
      {
        Caption = 'US-Expiry Date';
      }
      column(PurchasingBlocked; "Purchasing Blocked")
      {
        Caption = 'Purchasing Blocked';
      }
      column(ExpiredCancelled; "Expired/Cancelled")
      {
        Caption = 'Expired/Cancelled';
      }

      trigger OnPreDataItem()
      begin
        Item.SetFilter("US-Expiry Date", '<>%1&<=%2', 0D, CalcDate('<1M>', Today()));
      end;

      trigger OnAfterGetRecord()
      begin
        if Item."Purchasing Blocked" and Item."Expired/Cancelled" then
          CurrReport.Skip();
      end;
    }
  }

  rendering
  {
    layout(USExpiryDateAudit)
    {
      Type = RDLC;
      LayoutFile = './src/Layouts/USExpiryDateAudit.rdl';
      Caption = 'US Expiry Date Audit';
    }
  }
}
