table 50101 "CCO Packaging BOM"
{
  Caption = 'Packaging BOM';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "Specification No."; Code[20])
    {
      Caption = 'Specification No.';
      ToolTip = 'Specifies the packaging specification that the BOM belongs to.', Comment = 'hu-HU=Megadja a csomagolási specifikációt, amelyhez a darabjegyzék tartozik.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Specification";
      NotBlank = true;
    }
    field(2; Description; Text[100])
    {
      Caption = 'Description';
      ToolTip = 'Specifies the description of the packaging specification.', Comment = 'hu-HU=Megadja a csomagolási specifikáció leírását.';
      DataClassification = CustomerContent;
    }
    field(3; "Calculation Date"; Date)
    {
      Caption = 'Calculation Date';
      ToolTip = 'Specifies when the components were last calculated from the specification.', Comment = 'hu-HU=Megadja, mikor számították ki utoljára az összetevőket a specifikációból.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(4; "Production BOM No."; Code[20])
    {
      Caption = 'Production BOM No.';
      ToolTip = 'Specifies the certified production BOM that was generated from this packaging BOM.', Comment = 'hu-HU=Megadja a csomagolási darabjegyzékből generált, jóváhagyott gyártási darabjegyzéket.';
      DataClassification = CustomerContent;
      TableRelation = "Production BOM Header";
      Editable = false;
    }
  }

  keys
  {
    key(PK; "Specification No.")
    {
      Clustered = true;
    }
  }

  trigger OnDelete()
  var
    PackagingBOMLine: Record "CCO Packaging BOM Line";
  begin
    PackagingBOMLine.SetRange("Specification No.", "Specification No.");
    PackagingBOMLine.DeleteAll(true);
  end;
}
