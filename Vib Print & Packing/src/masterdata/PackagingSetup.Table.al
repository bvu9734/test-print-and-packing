table 50106 "CCO Packaging Setup"
{
  Caption = 'Packaging Setup';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "Primary Key"; Code[10])
    {
      Caption = 'Primary Key';
      ToolTip = 'Specifies the key of the packaging setup record.', Comment = 'hu-HU=Megadja a csomagolási beállítás rekord kulcsát.';
      DataClassification = SystemMetadata;
    }
    field(2; "Packaging Spec. Nos."; Code[20])
    {
      Caption = 'Packaging Spec. Nos.';
      ToolTip = 'Specifies the number series used to assign codes to packaging specifications.', Comment = 'hu-HU=Megadja a csomagolási specifikációk kódjainak kiosztására használt számsort.';
      DataClassification = CustomerContent;
      TableRelation = "No. Series";
    }
    field(3; "Cost Sheet Nos."; Code[20])
    {
      Caption = 'Cost Sheet Nos.';
      ToolTip = 'Specifies the number series used to assign numbers to packaging cost sheets.', Comment = 'hu-HU=Megadja a csomagolási költséglapok számainak kiosztására használt számsort.';
      DataClassification = CustomerContent;
      TableRelation = "No. Series";
    }
    field(4; "Item Nos."; Code[20])
    {
      Caption = 'Item Nos.';
      ToolTip = 'Specifies the number series used for the finished items created when a packaging specification is released.', Comment = 'hu-HU=Megadja a csomagolási specifikáció kiadásakor létrehozott késztermék cikkek számsorát.';
      DataClassification = CustomerContent;
      TableRelation = "No. Series";
    }
    field(5; "Item Template Code"; Code[20])
    {
      Caption = 'Item Template Code';
      ToolTip = 'Specifies the item template applied to finished items created when a packaging specification is released.', Comment = 'hu-HU=Megadja a csomagolási specifikáció kiadásakor létrehozott késztermék cikkekre alkalmazott cikksablont.';
      DataClassification = CustomerContent;
      TableRelation = "Item Templ.";
    }
    field(10; "Ink Item No."; Code[20])
    {
      Caption = 'Ink Item No.';
      ToolTip = 'Specifies the item that represents printing ink. Its unit cost is used to calculate ink cost.', Comment = 'hu-HU=Megadja a nyomdafestéket jelölő cikket. Az egységköltsége alapján számítjuk a festékköltséget.';
      DataClassification = CustomerContent;
      TableRelation = Item;
    }
    field(11; "Ink Qty. per m² per Color"; Decimal)
    {
      Caption = 'Ink Qty. per m² per Color';
      ToolTip = 'Specifies the ink quantity, in the base unit of measure of the ink item, consumed per square meter for each color.', Comment = 'hu-HU=Megadja a színenként, négyzetméterenként felhasznált festékmennyiséget a festékcikk alap mértékegységében.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
    field(12; "Glue Item No."; Code[20])
    {
      Caption = 'Glue Item No.';
      ToolTip = 'Specifies the item that represents glue. Its unit cost is used to calculate glue cost.', Comment = 'hu-HU=Megadja a ragasztót jelölő cikket. Az egységköltsége alapján számítjuk a ragasztóköltséget.';
      DataClassification = CustomerContent;
      TableRelation = Item;
    }
    field(13; "Glue Qty. per Piece"; Decimal)
    {
      Caption = 'Glue Qty. per Piece';
      ToolTip = 'Specifies the glue quantity, in the base unit of measure of the glue item, consumed per piece.', Comment = 'hu-HU=Megadja a darabonként felhasznált ragasztómennyiséget a ragasztócikk alap mértékegységében.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
    field(14; "Lamination Film Item No."; Code[20])
    {
      Caption = 'Lamination Film Item No.';
      ToolTip = 'Specifies the film item used for lamination. Its cost per m² is used to calculate lamination cost.', Comment = 'hu-HU=Megadja a lamináláshoz használt fóliacikket. A négyzetméterenkénti költsége alapján számítjuk a laminálási költséget.';
      DataClassification = CustomerContent;
      TableRelation = Item;
    }
    field(15; "Lamination Cost per Piece"; Decimal)
    {
      Caption = 'Lamination Cost per Piece';
      ToolTip = 'Specifies the lamination process cost added per piece when a specification uses lamination.', Comment = 'hu-HU=Megadja a laminálási művelet darabonkénti költségét, amelyet laminált specifikációknál számítunk fel.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
  }

  keys
  {
    key(PK; "Primary Key")
    {
      Clustered = true;
    }
  }
}
