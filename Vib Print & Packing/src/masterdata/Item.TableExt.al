tableextension 50112 "CCO Item Ext." extends Item
{
  fields
  {
    field(50100; "CCO Packaging Material Type"; Enum "CCO Material Type")
    {
      Caption = 'Packaging Material Type';
      ToolTip = 'Specifies the packaging material type, such as paper, corrugated board, ink, glue, foil, or film.', Comment = 'hu-HU=Megadja a csomagolóanyag típusát, például papírt, hullámkartont, tintát, ragasztót, fóliát vagy filmet.';
      DataClassification = CustomerContent;
    }
    field(50101; "CCO Material GSM"; Decimal)
    {
      Caption = 'GSM';
      ToolTip = 'Specifies the material weight in grams per square meter.', Comment = 'hu-HU=Megadja az anyag négyzetméterenkénti tömegét grammban.';
      DataClassification = CustomerContent;
    }
    field(50102; "CCO Material Width (mm)"; Decimal)
    {
      Caption = 'Material Width (mm)';
      ToolTip = 'Specifies the material width in millimeters.', Comment = 'hu-HU=Megadja az anyag szélességét milliméterben.';
      DataClassification = CustomerContent;
    }
    field(50103; "CCO Material Length (mm)"; Decimal)
    {
      Caption = 'Material Length (mm)';
      ToolTip = 'Specifies the material length in millimeters.', Comment = 'hu-HU=Megadja az anyag hosszát milliméterben.';
      DataClassification = CustomerContent;
    }
    field(50104; "CCO Cost per m²"; Decimal)
    {
      Caption = 'Cost per m²';
      ToolTip = 'Specifies the cost of one square meter of the material.', Comment = 'hu-HU=Megadja az anyag egy négyzetméterének költségét.';
      DataClassification = CustomerContent;
    }
    field(50105; "CCO Packaging Spec. No."; Code[20])
    {
      Caption = 'Packaging Spec. No.';
      ToolTip = 'Specifies the packaging specification that this finished item was created from.', Comment = 'hu-HU=Megadja a csomagolási specifikációt, amelyből ez a késztermék cikk létrejött.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Specification";
      Editable = false;
    }
  }
}
