table 50103 "CCO Packaging Cost Sheet"
{
  Caption = 'Packaging Cost Sheet';
  DataClassification = CustomerContent;
  LookupPageId = "CCO Packaging Cost Sheets";
  DrillDownPageId = "CCO Packaging Cost Sheets";

  fields
  {
    field(1; "No."; Code[20])
    {
      Caption = 'No.';
      ToolTip = 'Specifies the number of the cost sheet.', Comment = 'hu-HU=Megadja a költséglap számát.';
      DataClassification = CustomerContent;
    }
    field(2; "Specification No."; Code[20])
    {
      Caption = 'Specification No.';
      ToolTip = 'Specifies the packaging specification that is costed.', Comment = 'hu-HU=Megadja a kalkulált csomagolási specifikációt.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Specification";

      trigger OnValidate()
      var
        PackagingSpecification: Record "CCO Packaging Specification";
      begin
        "Calculation Date" := 0D;
        if "Specification No." = '' then
          exit;

        PackagingSpecification.Get("Specification No.");
        Description := PackagingSpecification.Description;
        Validate("Customer No.", PackagingSpecification."Customer No.");
      end;
    }
    field(3; Description; Text[100])
    {
      Caption = 'Description';
      ToolTip = 'Specifies a description of the cost sheet.', Comment = 'hu-HU=Megadja a költséglap leírását.';
      DataClassification = CustomerContent;
    }
    field(4; "Customer No."; Code[20])
    {
      Caption = 'Customer No.';
      ToolTip = 'Specifies the customer the cost sheet is prepared for. The default margin of the customer is copied to the cost sheet.', Comment = 'hu-HU=Megadja a vevőt, akinek a költséglap készül. A vevő alapértelmezett árrése átkerül a költséglapra.';
      DataClassification = CustomerContent;
      TableRelation = Customer;

      trigger OnValidate()
      var
        Customer: Record Customer;
      begin
        if Customer.Get("Customer No.") then
          Validate("Margin %", Customer."CCO Packaging Margin %")
        else
          Validate("Margin %", 0);
      end;
    }
    field(5; "Margin %"; Decimal)
    {
      Caption = 'Margin %';
      ToolTip = 'Specifies the markup percentage added to the unit cost to calculate the unit price.', Comment = 'hu-HU=Megadja az egységköltségre felszámított árrés százalékát, amelyből az egységár adódik.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;

      trigger OnValidate()
      var
        CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";
      begin
        CostEngineMgt.UpdateLinePrices(Rec);
      end;
    }
    field(6; "Calculation Date"; Date)
    {
      Caption = 'Calculation Date';
      ToolTip = 'Specifies when the cost sheet was last calculated. It is cleared when the specification changes.', Comment = 'hu-HU=Megadja, mikor számították ki utoljára a költséglapot. A specifikáció módosításakor törlődik.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(10; "Width (mm)"; Decimal)
    {
      Caption = 'Width (mm)';
      ToolTip = 'Specifies the packaging width in millimeters used in the calculation.', Comment = 'hu-HU=Megadja a számításban használt csomagolási szélességet milliméterben.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(11; "Height (mm)"; Decimal)
    {
      Caption = 'Height (mm)';
      ToolTip = 'Specifies the packaging height in millimeters used in the calculation.', Comment = 'hu-HU=Megadja a számításban használt csomagolási magasságot milliméterben.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(12; "Waste %"; Decimal)
    {
      Caption = 'Waste %';
      ToolTip = 'Specifies the material waste percentage used in the calculation.', Comment = 'hu-HU=Megadja a számításban használt anyagveszteség százalékát.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(13; "Material Item No."; Code[20])
    {
      Caption = 'Material Item No.';
      ToolTip = 'Specifies the packaging material item used in the calculation.', Comment = 'hu-HU=Megadja a számításban használt csomagolóanyag cikket.';
      DataClassification = CustomerContent;
      TableRelation = Item;
      Editable = false;
    }
    field(14; "Print Process"; Enum "CCO Print Process")
    {
      Caption = 'Print Process';
      ToolTip = 'Specifies the print process used in the calculation.', Comment = 'hu-HU=Megadja a számításban használt nyomtatási eljárást.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(15; "No. of Colors"; Integer)
    {
      Caption = 'No. of Colors';
      ToolTip = 'Specifies the number of colors used in the calculation.', Comment = 'hu-HU=Megadja a számításban használt színek számát.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(16; Lamination; Boolean)
    {
      Caption = 'Lamination';
      ToolTip = 'Specifies whether lamination was included in the calculation.', Comment = 'hu-HU=Megadja, hogy a számítás tartalmazta-e a laminálást.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(17; "Die Cut"; Boolean)
    {
      Caption = 'Die Cut';
      ToolTip = 'Specifies whether die cutting was included in the calculation.', Comment = 'hu-HU=Megadja, hogy a számítás tartalmazta-e a stancolást.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(20; "Base Area (m²)"; Decimal)
    {
      Caption = 'Base Area (m²)';
      ToolTip = 'Specifies the material area per piece, calculated as height × width / 1,000,000.', Comment = 'hu-HU=Megadja a darabonkénti anyagfelületet: magasság × szélesség / 1 000 000.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(21; "Required Area (m²)"; Decimal)
    {
      Caption = 'Required Area (m²)';
      ToolTip = 'Specifies the material area per piece including waste.', Comment = 'hu-HU=Megadja a darabonkénti anyagfelületet a hulladékkal együtt.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(22; "Material Cost"; Decimal)
    {
      Caption = 'Material Cost';
      ToolTip = 'Specifies the material cost per piece: required area × material cost per m².', Comment = 'hu-HU=Megadja a darabonkénti anyagköltséget: szükséges felület × anyag négyzetméterára.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(23; "Ink Cost"; Decimal)
    {
      Caption = 'Ink Cost';
      ToolTip = 'Specifies the ink cost per piece based on the required area, number of colors, and ink consumption.', Comment = 'hu-HU=Megadja a darabonkénti festékköltséget a szükséges felület, a színek száma és a festékfelhasználás alapján.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(24; "Glue Cost"; Decimal)
    {
      Caption = 'Glue Cost';
      ToolTip = 'Specifies the glue cost per piece.', Comment = 'hu-HU=Megadja a darabonkénti ragasztóköltséget.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(25; "Lamination Cost"; Decimal)
    {
      Caption = 'Lamination Cost';
      ToolTip = 'Specifies the lamination cost per piece, including film and process cost.', Comment = 'hu-HU=Megadja a darabonkénti laminálási költséget a fóliával és a művelettel együtt.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(26; "Printing Cost"; Decimal)
    {
      Caption = 'Printing Cost';
      ToolTip = 'Specifies the printing cost per piece from the print cost matrix.', Comment = 'hu-HU=Megadja a darabonkénti nyomtatási költséget a nyomtatási költségmátrix alapján.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(27; "Labor Cost"; Decimal)
    {
      Caption = 'Labor Cost';
      ToolTip = 'Specifies the labor cost per piece from the print cost matrix.', Comment = 'hu-HU=Megadja a darabonkénti munkaerőköltséget a nyomtatási költségmátrix alapján.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(28; "Variable Unit Cost"; Decimal)
    {
      Caption = 'Variable Unit Cost';
      ToolTip = 'Specifies the sum of the per-piece costs, excluding fixed costs.', Comment = 'hu-HU=Megadja a darabonkénti költségek összegét a fix költségek nélkül.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(29; "Machine Setup Cost"; Decimal)
    {
      Caption = 'Machine Setup Cost';
      ToolTip = 'Specifies the fixed machine setup cost per order from the print cost matrix.', Comment = 'hu-HU=Megadja a rendelésenkénti fix gépbeállítási költséget a nyomtatási költségmátrix alapján.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(30; "Die Cost"; Decimal)
    {
      Caption = 'Die Cost';
      ToolTip = 'Specifies the die cost per order. It is zero when the specification does not require die cutting.', Comment = 'hu-HU=Megadja a rendelésenkénti stancszerszám-költséget. Nulla, ha a specifikáció nem igényel stancolást.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(31; "Fixed Cost"; Decimal)
    {
      Caption = 'Fixed Cost';
      ToolTip = 'Specifies the total fixed cost per order: machine setup cost plus die cost.', Comment = 'hu-HU=Megadja a rendelésenkénti összes fix költséget: gépbeállítási költség és stancszerszám-költség.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(40; "Sales Quote No."; Code[20])
    {
      Caption = 'Sales Quote No.';
      ToolTip = 'Specifies the sales quote that was created from this cost sheet.', Comment = 'hu-HU=Megadja az erről a költséglapról létrehozott értékesítési árajánlatot.';
      DataClassification = CustomerContent;
      TableRelation = "Sales Header"."No." where("Document Type" = const(Quote));
      Editable = false;
    }
  }

  keys
  {
    key(PK; "No.")
    {
      Clustered = true;
    }
    key(Specification; "Specification No.")
    {
    }
  }

  trigger OnInsert()
  var
    PackagingSetup: Record "CCO Packaging Setup";
    NoSeries: Codeunit "No. Series";
  begin
    if "No." <> '' then
      exit;

    PackagingSetup.Get();
    PackagingSetup.TestField("Cost Sheet Nos.");
    "No." := NoSeries.GetNextNo(PackagingSetup."Cost Sheet Nos.");
  end;

  trigger OnDelete()
  var
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    CostSheetLine.SetRange("Cost Sheet No.", "No.");
    CostSheetLine.DeleteAll();
  end;
}
