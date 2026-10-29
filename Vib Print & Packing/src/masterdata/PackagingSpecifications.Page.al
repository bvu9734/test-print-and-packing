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
          ToolTip = 'Specifies the unique code for the packaging specification.';
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
          ToolTip = 'Specifies a description of the packaging specification.';
        }
        field("Customer No."; Rec."Customer No.")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the customer associated with the packaging specification.';
        }
        field("Material Code"; Rec."Material Code")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the item used as the packaging material.';
        }
        field("Print Process"; Rec."Print Process")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the print process used for the packaging.';
        }
        field(Status; Rec.Status)
        {
          ApplicationArea = All;
          ToolTip = 'Specifies whether the packaging specification is a draft or released.';
        }
      }
    }
  }
}
