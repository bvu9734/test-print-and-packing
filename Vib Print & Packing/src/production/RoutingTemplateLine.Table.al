table 50141 "CCO Routing Template Line"
{
  Caption = 'Packaging Routing Template Line';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "Template Code"; Code[20])
    {
      Caption = 'Template Code';
      ToolTip = 'Specifies the routing template that the operation belongs to.', Comment = 'hu-HU=Megadja a műveleti sablont, amelyhez a művelet tartozik.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Routing Template";
    }
    field(2; "Operation No."; Code[10])
    {
      Caption = 'Operation No.';
      ToolTip = 'Specifies the operation number. Operations are performed in the order of their numbers, for example 10, 20, 30.', Comment = 'hu-HU=Megadja a műveletszámot. A műveletek a számuk sorrendjében követik egymást, például 10, 20, 30.';
      DataClassification = CustomerContent;
      NotBlank = true;
    }
    field(3; "Work Center No."; Code[20])
    {
      Caption = 'Work Center No.';
      ToolTip = 'Specifies the work center that performs the operation.', Comment = 'hu-HU=Megadja a műveletet végző munkahelyet.';
      DataClassification = CustomerContent;
      TableRelation = "Work Center";

      trigger OnValidate()
      var
        WorkCenter: Record "Work Center";
      begin
        if (Description = '') and WorkCenter.Get("Work Center No.") then
          Description := WorkCenter.Name;
      end;
    }
    field(4; Description; Text[100])
    {
      Caption = 'Description';
      ToolTip = 'Specifies the description of the operation.', Comment = 'hu-HU=Megadja a művelet leírását.';
      DataClassification = CustomerContent;
    }
    field(5; "Setup Time"; Decimal)
    {
      Caption = 'Setup Time';
      ToolTip = 'Specifies the setup time of the operation, in the capacity unit of measure of the work center.', Comment = 'hu-HU=Megadja a művelet beállítási idejét a munkahely kapacitás-mértékegységében.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
    field(6; "Run Time"; Decimal)
    {
      Caption = 'Run Time';
      ToolTip = 'Specifies the run time per piece of the operation, in the capacity unit of measure of the work center.', Comment = 'hu-HU=Megadja a művelet darabonkénti futásidejét a munkahely kapacitás-mértékegységében.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
    field(7; Condition; Enum "CCO Operation Condition")
    {
      Caption = 'Condition';
      ToolTip = 'Specifies when the operation is included in a generated routing: always, only if the specification is die cut, only if it is laminated, or only if it is printed (has colors).', Comment = 'hu-HU=Megadja, mikor kerül a művelet a generált műveleti tervbe: mindig, csak stancolt, csak laminált, vagy csak nyomtatott (színekkel rendelkező) specifikáció esetén.';
      DataClassification = CustomerContent;
    }
  }

  keys
  {
    key(PK; "Template Code", "Operation No.")
    {
      Clustered = true;
    }
  }
}
