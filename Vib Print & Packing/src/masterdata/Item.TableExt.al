tableextension 50112 "CCO Item Ext." extends Item
{
  fields
  {
    field(50100; "CCO Packaging Material Type"; Enum "CCO Material Type")
    {
      Caption = 'Packaging Material Type';
      DataClassification = CustomerContent;
    }
    field(50101; "CCO Material GSM"; Decimal)
    {
      Caption = 'GSM';
      DataClassification = CustomerContent;
    }
    field(50102; "CCO Material Width (mm)"; Decimal)
    {
      Caption = 'Material Width (mm)';
      DataClassification = CustomerContent;
    }
    field(50103; "CCO Material Length (mm)"; Decimal)
    {
      Caption = 'Material Length (mm)';
      DataClassification = CustomerContent;
    }
    field(50104; "CCO Cost per m²"; Decimal)
    {
      Caption = 'Cost per m²';
      DataClassification = CustomerContent;
    }
  }
}
