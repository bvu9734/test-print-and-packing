table 50104 "CCO Packaging Cost Sheet Line"
{
  Caption = 'Packaging Cost Sheet Line';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "Cost Sheet No."; Code[20])
    {
      Caption = 'Cost Sheet No.';
      ToolTip = 'Specifies the cost sheet that the line belongs to.', Comment = 'hu-HU=Megadja a költséglapot, amelyhez a sor tartozik.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Cost Sheet";
    }
    field(2; "Line No."; Integer)
    {
      Caption = 'Line No.';
      ToolTip = 'Specifies the number of the line.', Comment = 'hu-HU=Megadja a sor számát.';
      DataClassification = CustomerContent;
    }
    field(3; Quantity; Decimal)
    {
      Caption = 'Quantity';
      ToolTip = 'Specifies the order quantity to calculate a price for.', Comment = 'hu-HU=Megadja a rendelési mennyiséget, amelyre árat számítunk.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;

      trigger OnValidate()
      var
        CostSheet: Record "CCO Packaging Cost Sheet";
        CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";
        QuantityErr: Label 'Quantity must be greater than zero.';
      begin
        if Quantity <= 0 then
          Error(QuantityErr);

        CostSheet.Get("Cost Sheet No.");
        if CostSheet."Calculation Date" <> 0D then
          CostEngineMgt.CalculateLine(CostSheet, Rec);
      end;
    }
    field(4; "Fixed Cost per Piece"; Decimal)
    {
      Caption = 'Fixed Cost per Piece';
      ToolTip = 'Specifies the fixed cost per piece: fixed cost divided by the quantity.', Comment = 'hu-HU=Megadja a darabonkénti fix költséget: fix költség osztva a mennyiséggel.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(5; "Unit Cost"; Decimal)
    {
      Caption = 'Unit Cost';
      ToolTip = 'Specifies the total cost per piece at this quantity: variable unit cost plus fixed cost per piece.', Comment = 'hu-HU=Megadja az ennél a mennyiségnél érvényes teljes darabonkénti költséget: változó egységköltség plusz darabonkénti fix költség.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(6; "Unit Price"; Decimal)
    {
      Caption = 'Unit Price';
      ToolTip = 'Specifies the sales price per piece: unit cost plus margin.', Comment = 'hu-HU=Megadja a darabonkénti eladási árat: egységköltség plusz árrés.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(7; "Line Amount"; Decimal)
    {
      Caption = 'Line Amount';
      ToolTip = 'Specifies the total sales price for the quantity.', Comment = 'hu-HU=Megadja a mennyiség teljes eladási árát.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
  }

  keys
  {
    key(PK; "Cost Sheet No.", "Line No.")
    {
      Clustered = true;
    }
  }
}
