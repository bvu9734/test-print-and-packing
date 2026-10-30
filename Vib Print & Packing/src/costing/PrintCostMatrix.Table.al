table 50120 "CCO Print Cost Matrix"
{
  Caption = 'Print Cost Matrix';
  DataClassification = CustomerContent;
  LookupPageId = "CCO Print Cost Matrix";
  DrillDownPageId = "CCO Print Cost Matrix";

  fields
  {
    field(1; "Print Process"; Enum "CCO Print Process")
    {
      Caption = 'Print Process';
      ToolTip = 'Specifies the print process that the rates apply to.', Comment = 'hu-HU=Megadja a nyomtatási eljárást, amelyre a díjak vonatkoznak.';
      DataClassification = CustomerContent;

      trigger OnValidate()
      begin
        CheckPrintProcess();
      end;
    }
    field(2; "Print Cost per Piece"; Decimal)
    {
      Caption = 'Print Cost per Piece';
      ToolTip = 'Specifies the printing cost per piece for the print process.', Comment = 'hu-HU=Megadja a nyomtatási eljárás darabonkénti nyomtatási költségét.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
    field(3; "Machine Setup Cost"; Decimal)
    {
      Caption = 'Machine Setup Cost';
      ToolTip = 'Specifies the fixed machine setup cost per order for the print process. It is spread over the order quantity.', Comment = 'hu-HU=Megadja a nyomtatási eljárás rendelésenkénti fix gépbeállítási költségét. A költséget a rendelési mennyiségre osztjuk szét.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
    field(4; "Labor Cost per Piece"; Decimal)
    {
      Caption = 'Labor Cost per Piece';
      ToolTip = 'Specifies the labor cost per piece for the print process.', Comment = 'hu-HU=Megadja a nyomtatási eljárás darabonkénti munkaerőköltségét.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
  }

  keys
  {
    key(PK; "Print Process")
    {
      Clustered = true;
    }
  }

  trigger OnInsert()
  begin
    CheckPrintProcess();
  end;

  local procedure CheckPrintProcess()
  var
    SelectPrintProcessErr: Label 'Select a print process.';
  begin
    if "Print Process" = "Print Process"::None then
      Error(SelectPrintProcessErr);
  end;
}
