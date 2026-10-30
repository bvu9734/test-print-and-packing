table 50134 "CCO Packaging Wksh. Name"
{
  Caption = 'Packaging Worksheet Name';
  DataClassification = CustomerContent;
  LookupPageId = "CCO Packaging Wksh. Names";
  DrillDownPageId = "CCO Packaging Wksh. Names";

  fields
  {
    field(1; Name; Code[10])
    {
      Caption = 'Name';
      ToolTip = 'Specifies the name of the packaging worksheet batch.', Comment = 'hu-HU=Megadja a csomagolási munkalap kötegének nevét.';
      DataClassification = CustomerContent;
      NotBlank = true;
    }
    field(2; Description; Text[100])
    {
      Caption = 'Description';
      ToolTip = 'Specifies a description of the packaging worksheet batch.', Comment = 'hu-HU=Megadja a csomagolási munkalap kötegének leírását.';
      DataClassification = CustomerContent;
    }
  }

  keys
  {
    key(PK; Name)
    {
      Clustered = true;
    }
  }

  trigger OnDelete()
  var
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
  begin
    PackagingWkshLine.SetRange("Worksheet Name", Name);
    PackagingWkshLine.DeleteAll(true);
  end;
}
