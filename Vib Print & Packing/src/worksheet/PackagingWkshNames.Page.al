page 50138 "CCO Packaging Wksh. Names"
{
  Caption = 'Packaging Worksheet Names';
  PageType = List;
  SourceTable = "CCO Packaging Wksh. Name";
  ApplicationArea = All;

  layout
  {
    area(Content)
    {
      repeater(General)
      {
        field(Name; Rec.Name)
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
