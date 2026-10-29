page 50115 "CCO Packaging Setup"
{
  Caption = 'Packaging Setup';
  PageType = Card;
  SourceTable = "CCO Packaging Setup";
  ApplicationArea = All;
  UsageCategory = Administration;

  layout
  {
    area(Content)
    {
      group(General)
      {
        Caption = 'General';

        field("Packaging Spec. Nos."; Rec."Packaging Spec. Nos.")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the number series used to assign codes to packaging specifications.';
        }
      }
    }
  }

  trigger OnOpenPage()
  begin
    if not Rec.Get('') then begin
      Rec.Init();
      Rec.Insert();
    end;
  end;
}
