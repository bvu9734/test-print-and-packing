page 50143 "CCO Routing Template"
{
  Caption = 'Packaging Routing Template';
  PageType = Document;
  SourceTable = "CCO Routing Template";
  ApplicationArea = All;

  layout
  {
    area(Content)
    {
      group(General)
      {
        Caption = 'General';

        field("Code"; Rec."Code")
        {
          ApplicationArea = All;
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
        }
      }
      part(Lines; "CCO Routing Template Subform")
      {
        ApplicationArea = All;
        Caption = 'Operations';
        SubPageLink = "Template Code" = field("Code");
      }
    }
  }
}
