tableextension 50123 "CCO Customer Ext." extends Customer
{
  fields
  {
    field(50100; "CCO Packaging Margin %"; Decimal)
    {
      Caption = 'Packaging Margin %';
      ToolTip = 'Specifies the default markup percentage added to the calculated cost on packaging cost sheets for this customer.', Comment = 'hu-HU=Megadja az alapértelmezett árrés százalékot, amelyet a vevő csomagolási költséglapjain a számított költségre felszámítunk.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
  }
}
