table 50140 "CCO Routing Template"
{
  Caption = 'Packaging Routing Template';
  DataClassification = CustomerContent;
  LookupPageId = "CCO Routing Templates";
  DrillDownPageId = "CCO Routing Templates";

  fields
  {
    field(1; "Code"; Code[20])
    {
      Caption = 'Code';
      ToolTip = 'Specifies the code of the routing template, for example BOX_STD.', Comment = 'hu-HU=Megadja a műveleti sablon kódját, például BOX_STD.';
      DataClassification = CustomerContent;
      NotBlank = true;
    }
    field(2; Description; Text[100])
    {
      Caption = 'Description';
      ToolTip = 'Specifies a description of the routing template.', Comment = 'hu-HU=Megadja a műveleti sablon leírását.';
      DataClassification = CustomerContent;
    }
  }

  keys
  {
    key(PK; "Code")
    {
      Clustered = true;
    }
  }

  trigger OnDelete()
  var
    RoutingTemplateLine: Record "CCO Routing Template Line";
  begin
    RoutingTemplateLine.SetRange("Template Code", "Code");
    RoutingTemplateLine.DeleteAll(true);
  end;
}
