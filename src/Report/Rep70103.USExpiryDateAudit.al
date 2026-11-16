
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
                ExpiryDateThreshold := CalcDate('<1M>', Today());
            end;

            trigger OnAfterGetRecord()
            var
                IsExpiryWithinThreshold: Boolean;
                ShouldBePurchasingBlocked: Boolean;
            begin
                if Item."US-Expiry Date" = 0D then
                    exit;

                IsExpiryWithinThreshold :=
                  (Item."US-Expiry Date" <= ExpiryDateThreshold);
                ShouldBePurchasingBlocked :=
                  Item."Purchasing Blocked" or IsExpiryWithinThreshold;
                if (Item."Purchasing Blocked" = ShouldBePurchasingBlocked) and
                   (Item."Expired/Cancelled" = IsExpiryWithinThreshold)
                then
                    exit;

                Item."Purchasing Blocked" := ShouldBePurchasingBlocked;
                Item."Expired/Cancelled" := IsExpiryWithinThreshold;
                Item.Modify(true);
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

    var
        ExpiryDateThreshold: Date;
}
