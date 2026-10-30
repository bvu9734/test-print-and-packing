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
      group(Numbering)
      {
        Caption = 'Numbering';

        field("Packaging Spec. Nos."; Rec."Packaging Spec. Nos.")
        {
          ApplicationArea = All;
        }
        field("Cost Sheet Nos."; Rec."Cost Sheet Nos.")
        {
          ApplicationArea = All;
        }
      }
      group(ItemCreation)
      {
        Caption = 'Item Creation';

        field("Item Nos."; Rec."Item Nos.")
        {
          ApplicationArea = All;
        }
        field("Item Template Code"; Rec."Item Template Code")
        {
          ApplicationArea = All;
        }
      }
      group(Consumption)
      {
        Caption = 'Consumption';

        field("Ink Item No."; Rec."Ink Item No.")
        {
          ApplicationArea = All;
        }
        field("Ink Qty. per m² per Color"; Rec."Ink Qty. per m² per Color")
        {
          ApplicationArea = All;
        }
        field("Glue Item No."; Rec."Glue Item No.")
        {
          ApplicationArea = All;
        }
        field("Glue Qty. per Piece"; Rec."Glue Qty. per Piece")
        {
          ApplicationArea = All;
        }
        field("Lamination Film Item No."; Rec."Lamination Film Item No.")
        {
          ApplicationArea = All;
        }
        field("Lamination Cost per Piece"; Rec."Lamination Cost per Piece")
        {
          ApplicationArea = All;
        }
      }
      group(RoutingTemplates)
      {
        Caption = 'Routing Templates';

        field("Digital Routing Template"; Rec."Digital Routing Template")
        {
          ApplicationArea = All;
        }
        field("Box Routing Template"; Rec."Box Routing Template")
        {
          ApplicationArea = All;
        }
        field("Label Routing Template"; Rec."Label Routing Template")
        {
          ApplicationArea = All;
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(GenerateDemoData)
      {
        ApplicationArea = All;
        Caption = 'Generate Demo Data';
        Image = CreateDocuments;
        ToolTip = 'Create demo master data for manual testing: number series, setup values, print rates, an item template, one material item per material type, customers, specifications, and a worksheet batch. Existing demo records and filled setup fields are kept.', Comment = 'hu-HU=Bemutató törzsadatok létrehozása kézi teszteléshez: számsorok, beállítási értékek, nyomtatási díjak, cikksablon, anyagtípusonként egy anyagcikk, vevők, specifikációk és egy munkalap köteg. A meglévő bemutató rekordok és a kitöltött beállítási mezők megmaradnak.';

        trigger OnAction()
        var
          PackagingDemoData: Codeunit "CCO Packaging Demo Data";
          GenerationSummary: Text;
        begin
          if not Confirm(GenerateDemoDataQst, false) then
            exit;
          CurrPage.SaveRecord();
          GenerationSummary := PackagingDemoData.Generate();
          CurrPage.Update(false);
          Message(GenerationSummary);
        end;
      }
    }
    area(Navigation)
    {
      action(PrintCostMatrix)
      {
        ApplicationArea = All;
        Caption = 'Print Cost Matrix';
        Image = Price;
        RunObject = page "CCO Print Cost Matrix";
        ToolTip = 'Open the printing, machine setup, and labor rates per print process.', Comment = 'hu-HU=Megnyitja a nyomtatási eljárásonkénti nyomtatási, gépbeállítási és munkaerő-díjakat.';
      }
      action(RoutingTemplatesAction)
      {
        ApplicationArea = All;
        Caption = 'Routing Templates';
        Image = Route;
        RunObject = page "CCO Routing Templates";
        ToolTip = 'Open the routing templates that routings for packaging specifications are generated from.', Comment = 'hu-HU=Megnyitja a műveleti sablonokat, amelyekből a csomagolási specifikációk műveleti tervei generálódnak.';
      }
    }
    area(Promoted)
    {
      actionref(PrintCostMatrix_Promoted; PrintCostMatrix)
      {
      }
      actionref(RoutingTemplates_Promoted; RoutingTemplatesAction)
      {
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

  var
    GenerateDemoDataQst: Label 'This creates demo master data for the packaging feature, including items, customers, specifications, and a worksheet batch. Use it only in a test or sandbox company.\\Do you want to continue?';
}
