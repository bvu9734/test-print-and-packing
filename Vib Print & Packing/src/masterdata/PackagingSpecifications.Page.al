page 50113 "CCO Packaging Specifications"
{
  Caption = 'Packaging Specifications';
  PageType = List;
  SourceTable = "CCO Packaging Specification";
  ApplicationArea = All;
  UsageCategory = Lists;
  CardPageId = "CCO Packaging Spec. Card";

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
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
        }
        field("Customer No."; Rec."Customer No.")
        {
          ApplicationArea = All;
        }
        field("Material Code"; Rec."Material Code")
        {
          ApplicationArea = All;
        }
        field("Print Process"; Rec."Print Process")
        {
          ApplicationArea = All;
        }
        field(Status; Rec.Status)
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
