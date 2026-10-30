table 50100 "CCO Packaging Specification"
{
  Caption = 'Packaging Specification';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "No."; Code[20])
    {
      Caption = 'No.';
      ToolTip = 'Specifies the unique code for the packaging specification. Leave blank to use the configured number series.', Comment = 'hu-HU=Meghatározza a csomagolási specifikáció egyedi kódját. Hagyja üresen a beállított számsor használatához.';
      DataClassification = CustomerContent;
    }
    field(2; Description; Text[100])
    {
      Caption = 'Description';
      ToolTip = 'Specifies the technical description of the packaging product.', Comment = 'hu-HU=Meghatározza a csomagolandó termék műszaki leírását.';
      DataClassification = CustomerContent;
    }
    field(3; "Customer No."; Code[20])
    {
      Caption = 'Customer No.';
      ToolTip = 'Specifies the customer associated with the packaging specification.', Comment = 'hu-HU=Megadja a csomagolási specifikációhoz tartozó vevőt.';
      DataClassification = CustomerContent;
      TableRelation = Customer."No.";
    }
    field(4; "Width (mm)"; Decimal)
    {
      Caption = 'Width (mm)';
      ToolTip = 'Specifies the packaging width in millimeters.', Comment = 'hu-HU=Megadja a csomagolás szélességét milliméterben.';
      DataClassification = CustomerContent;
    }
    field(5; "Length (mm)"; Decimal)
    {
      Caption = 'Length (mm)';
      ToolTip = 'Specifies the packaging length in millimeters.', Comment = 'hu-HU=Megadja a csomagolás hosszát milliméterben.';
      DataClassification = CustomerContent;
    }
    field(6; "Height (mm)"; Decimal)
    {
      Caption = 'Height (mm)';
      ToolTip = 'Specifies the packaging height in millimeters.', Comment = 'hu-HU=Megadja a csomagolás magasságát milliméterben.';
      DataClassification = CustomerContent;
    }
    field(7; "Material Code"; Code[20])
    {
      Caption = 'Material Code';
      ToolTip = 'Specifies the item used as the packaging material. The item must have a packaging material type.', Comment = 'hu-HU=Megadja a csomagolóanyagként használt cikket. A cikkhez csomagolóanyag-típust kell rendelni.';
      DataClassification = CustomerContent;
      TableRelation = Item."No.";

      trigger OnValidate()
      var
        MaterialItem: Record Item;
        PackagingItemTypeErr: Label 'Item %1 must be assigned a packaging material type.';
      begin
        if "Material Code" = '' then
          exit;

        MaterialItem.Get("Material Code");
        if MaterialItem."CCO Packaging Material Type" = MaterialItem."CCO Packaging Material Type"::None then
          Error(PackagingItemTypeErr, MaterialItem."No.");
      end;
    }
    field(8; "Material GSM"; Decimal)
    {
      Caption = 'Material GSM';
      ToolTip = 'Specifies the material weight in grams per square meter.', Comment = 'hu-HU=Megadja az anyag négyzetméterenkénti tömegét grammban.';
      DataClassification = CustomerContent;
    }
    field(9; "Print Process"; Enum "CCO Print Process")
    {
      Caption = 'Print Process';
      ToolTip = 'Specifies the print process used for the packaging: digital, offset, flexo, or screen.', Comment = 'hu-HU=Megadja a csomagoláshoz használt nyomtatási eljárást: digitális, ofszet, flexó vagy szitanyomás.';
      DataClassification = CustomerContent;
    }
    field(10; "No. of Colors"; Integer)
    {
      Caption = 'No. of Colors';
      ToolTip = 'Specifies the number of colors used in the print process.', Comment = 'hu-HU=Megadja a nyomtatási eljárásban használt színek számát.';
      DataClassification = CustomerContent;
    }
    field(11; Lamination; Boolean)
    {
      Caption = 'Lamination';
      ToolTip = 'Specifies whether the packaging uses lamination.', Comment = 'hu-HU=Megadja, hogy a csomagolás készül-e laminálással.';
      DataClassification = CustomerContent;
    }
    field(12; "Die Cut"; Boolean)
    {
      Caption = 'Die Cut';
      ToolTip = 'Specifies whether the packaging requires die cutting.', Comment = 'hu-HU=Megadja, hogy a csomagoláshoz szükséges-e stancolás.';
      DataClassification = CustomerContent;
    }
    field(13; "Waste %"; Decimal)
    {
      Caption = 'Waste %';
      ToolTip = 'Specifies the expected material waste percentage used in material calculations.', Comment = 'hu-HU=Megadja az anyagszükséglet számításakor figyelembe vett várható anyagveszteség százalékát.';
      DataClassification = CustomerContent;
    }
    field(14; Status; Enum "CCO Spec. Status")
    {
      Caption = 'Status';
      ToolTip = 'Specifies whether the specification is a draft or released. Released specifications remain editable.', Comment = 'hu-HU=Megadja, hogy a specifikáció piszkozat vagy kiadott állapotú. A kiadott specifikációk továbbra is szerkeszthetők.';
      DataClassification = CustomerContent;
    }
  }

  keys
  {
    key(PK; "No.")
    {
      Clustered = true;
    }
  }

  trigger OnInsert()
  var
    PackagingSetup: Record "CCO Packaging Setup";
    NoSeries: Codeunit "No. Series";
  begin
    if "No." <> '' then
      exit;

    if not PackagingSetup.Get('') then
      exit;

    if PackagingSetup."Packaging Spec. Nos." = '' then
      exit;

    "No." := NoSeries.GetNextNo(PackagingSetup."Packaging Spec. Nos.");
  end;
}
