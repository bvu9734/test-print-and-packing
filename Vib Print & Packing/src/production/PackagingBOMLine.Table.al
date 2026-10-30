table 50102 "CCO Packaging BOM Line"
{
  Caption = 'Packaging BOM Line';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "Specification No."; Code[20])
    {
      Caption = 'Specification No.';
      ToolTip = 'Specifies the packaging specification that the component belongs to.', Comment = 'hu-HU=Megadja a csomagolási specifikációt, amelyhez az összetevő tartozik.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging BOM";
    }
    field(2; "Line No."; Integer)
    {
      Caption = 'Line No.';
      ToolTip = 'Specifies the number of the line.', Comment = 'hu-HU=Megadja a sor számát.';
      DataClassification = CustomerContent;
    }
    field(3; "Item No."; Code[20])
    {
      Caption = 'Item No.';
      ToolTip = 'Specifies the component item.', Comment = 'hu-HU=Megadja az összetevő cikket.';
      DataClassification = CustomerContent;
      TableRelation = Item;

      trigger OnValidate()
      var
        Item: Record Item;
      begin
        Description := '';
        "Unit of Measure Code" := '';
        "Material Type" := "Material Type"::None;
        if Item.Get("Item No.") then begin
          Description := Item.Description;
          "Unit of Measure Code" := Item."Base Unit of Measure";
          "Material Type" := Item."CCO Packaging Material Type";
        end;
      end;
    }
    field(4; Description; Text[100])
    {
      Caption = 'Description';
      ToolTip = 'Specifies the description of the component.', Comment = 'hu-HU=Megadja az összetevő leírását.';
      DataClassification = CustomerContent;
    }
    field(5; "Material Type"; Enum "CCO Material Type")
    {
      Caption = 'Material Type';
      ToolTip = 'Specifies the packaging material type of the component item.', Comment = 'hu-HU=Megadja az összetevő cikk csomagolóanyag-típusát.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(6; "Quantity per"; Decimal)
    {
      Caption = 'Quantity per';
      ToolTip = 'Specifies the quantity of the component needed for one piece of the finished item, without scrap.', Comment = 'hu-HU=Megadja a késztermék egy darabjához szükséges összetevő-mennyiséget selejt nélkül.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
    field(7; "Unit of Measure Code"; Code[10])
    {
      Caption = 'Unit of Measure Code';
      ToolTip = 'Specifies the unit of measure of the quantity.', Comment = 'hu-HU=Megadja a mennyiség mértékegységét.';
      DataClassification = CustomerContent;
      TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
    }
    field(8; "Scrap %"; Decimal)
    {
      Caption = 'Scrap %';
      ToolTip = 'Specifies the expected scrap percentage of the component. It is taken from the waste percentage of the specification.', Comment = 'hu-HU=Megadja az összetevő várható selejtszázalékát. Értéke a specifikáció hulladékszázalékából származik.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;
    }
  }

  keys
  {
    key(PK; "Specification No.", "Line No.")
    {
      Clustered = true;
    }
  }
}
