page 50144 "CCO Routing Template Subform"
{
  Caption = 'Operations';
  PageType = ListPart;
  SourceTable = "CCO Routing Template Line";
  DelayedInsert = true;

  layout
  {
    area(Content)
    {
      repeater(General)
      {
        field("Operation No."; Rec."Operation No.")
        {
          ApplicationArea = All;
        }
        field("Work Center No."; Rec."Work Center No.")
        {
          ApplicationArea = All;
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
        }
        field("Setup Time"; Rec."Setup Time")
        {
          ApplicationArea = All;
        }
        field("Run Time"; Rec."Run Time")
        {
          ApplicationArea = All;
        }
        field(Condition; Rec.Condition)
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
