namespace TigerpakBC.TigerpakBC;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;

permissionset 70173 "Cash Receipt API"
{
    Assignable = true;
    Caption = 'Cash Receipt API';

    Permissions =
        page "Cash Receipt Journal API" = X,
        page "Customer Ledger Apply API" = X,
        codeunit "Cash Receipt Application" = X,
        tabledata "Gen. Journal Line" = RIM,
        tabledata "Gen. Journal Template" = R,
        tabledata "Gen. Journal Batch" = R,
        tabledata "Cust. Ledger Entry" = R;
}
