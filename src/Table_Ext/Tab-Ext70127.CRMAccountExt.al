namespace TigerpakBC.TigerpakBC;

using Microsoft.Integration.D365Sales;

tableextension 70127 "CRM AccountExt" extends "CRM Account"
{
    fields
    {
        field(70100; "Marketing Industry"; Text[50])
        {
            ExternalName = 'tp_marketingindustry';
            ExternalType = 'String';
            Description = '';
            Caption = 'Marketing Industry';
        }
        field(70110; "Company Size_Text"; Text[20])
        {
            ExternalName = 'tp_companysize_text';
            ExternalType = 'String';
            Description = '';
            Caption = 'Company Size';
        }
        field(70120; "Last Appointment Date"; Date)
        {
            ExternalName = 'wtec_lastappointmentdate';
            ExternalType = 'DateTime';
            Description = '';
            Caption = 'Last Appointment Date';
        }
    }
}
