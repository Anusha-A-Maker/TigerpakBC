namespace Tigerpak;

using ALProject.ALProject;
using TigerpakBC.TigerpakBC;

permissionset 70101 GeneratedPermtp
{
    Assignable = true;
    Permissions = codeunit "EventSubscribers1" = X,
        codeunit EventSubscriptionSQ = X,
        tabledata "User Configuration" = RIMD,
        table "User Configuration" = X,
        page "User Configuration " = X,
        report "TP Custom Sales Cr. Memo" = X,
        page "Master Sales Quote Lines" = X,
        page "TP Sales Invoiced API TS" = X,
        page "TP Sales Lines" = X,
        page "TP Salesorder Timestamps" = X,
        page TPCustomerledgerentryTS = X,
        tabledata "Market Industry Category" = RIMD,
        tabledata "Marketing Industry SubCategory" = RIMD,
        table "Market Industry Category" = X,
        table "Marketing Industry SubCategory" = X,
        page "Market Industry_Category" = X,
        page "Marketing Industry_SubCat" = X,
        tabledata "Dangerous Goods" = RIMD,
        tabledata "GIT Availability" = RIMD,
        tabledata Hazchem_DG = RIMD,
        tabledata "Package Type_DG" = RIMD,
        tabledata "Packing Group_DG" = RIMD,
        tabledata Shipping_DG = RIMD,
        tabledata "Top10DormantItems Buffer" = RIMD,
        tabledata "UN Number_DG" = RIMD,
        table "Dangerous Goods" = X,
        table "GIT Availability" = X,
        table Hazchem_DG = X,
        table "Package Type_DG" = X,
        table "Packing Group_DG" = X,
        table Shipping_DG = X,
        table "Top10DormantItems Buffer" = X,
        table "UN Number_DG" = X,
        report "Dispatch Summary Report" = X,
        report "TP Customer Statistics " = X,
        page "Dangerous Goods" = X,
        page "Get Tracking Data " = X,
        page "GIT Availability" = X,
        page Hazchem_DG = X,
        page "Master Sales Quote Lines_API" = X,
        page "Package Type_DG" = X,
        page "Packing Group_DG" = X,
        page "Price List Lines" = X,
        page Shipping_DG = X,
        page "UN Number_DG" = X;
}