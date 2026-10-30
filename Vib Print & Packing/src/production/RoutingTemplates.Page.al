page 50142 "CCO Routing Templates"
{
  Caption = 'Packaging Routing Templates';
  PageType = List;
  SourceTable = "CCO Routing Template";
  ApplicationArea = All;
  UsageCategory = Administration;
  CardPageId = "CCO Routing Template";
  Editable = false;

  layout
  {
    area(Content)
    {
      repeater(General)
      {
        field("Code"; Rec."Code")
        {
          ApplicationArea = All;
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
