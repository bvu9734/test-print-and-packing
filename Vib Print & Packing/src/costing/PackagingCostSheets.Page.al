page 50127 "CCO Packaging Cost Sheets"
{
  Caption = 'Packaging Cost Sheets';
  PageType = List;
  SourceTable = "CCO Packaging Cost Sheet";
  ApplicationArea = All;
  UsageCategory = Lists;
  CardPageId = "CCO Packaging Cost Sheet";
  Editable = false;

  layout
  {
    area(Content)
    {
      repeater(General)
      {
        field("No."; Rec."No.")
        {
          ApplicationArea = All;
        }
        field("Specification No."; Rec."Specification No.")
        {
          ApplicationArea = All;
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
        }
        field("Customer No."; Rec."Customer No.")
        {
          ApplicationArea = All;
        }
        field("Margin %"; Rec."Margin %")
        {
          ApplicationArea = All;
        }
        field("Variable Unit Cost"; Rec."Variable Unit Cost")
        {
          ApplicationArea = All;
        }
        field("Fixed Cost"; Rec."Fixed Cost")
        {
          ApplicationArea = All;
        }
        field("Calculation Date"; Rec."Calculation Date")
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
