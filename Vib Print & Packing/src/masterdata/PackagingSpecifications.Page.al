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
        field("Item No."; Rec."Item No.")
        {
          ApplicationArea = All;
        }
      }
    }
  }

  /// <summary>
  /// Returns the specifications the user selected on the page.
  /// </summary>
  /// <param name="PackagingSpecification">Returns the selected specifications as a filtered record.</param>
  procedure GetSelectedSpecifications(var PackagingSpecification: Record "CCO Packaging Specification")
  begin
    CurrPage.SetSelectionFilter(PackagingSpecification);
  end;
}
