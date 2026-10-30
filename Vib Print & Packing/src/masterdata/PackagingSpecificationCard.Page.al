page 50114 "CCO Packaging Spec. Card"
{
  Caption = 'Packaging Specification';
  PageType = Card;
  SourceTable = "CCO Packaging Specification";
  ApplicationArea = All;

  layout
  {
    area(Content)
    {
      group(General)
      {
        Caption = 'General';

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
        field(Status; Rec.Status)
        {
          ApplicationArea = All;
        }
        field("Item No."; Rec."Item No.")
        {
          ApplicationArea = All;
        }
        field("Routing Template Code"; Rec."Routing Template Code")
        {
          ApplicationArea = All;
        }
      }
      group(Dimensions)
      {
        Caption = 'Dimensions';

        field("Width (mm)"; Rec."Width (mm)")
        {
          ApplicationArea = All;
        }
        field("Length (mm)"; Rec."Length (mm)")
        {
          ApplicationArea = All;
        }
        field("Height (mm)"; Rec."Height (mm)")
        {
          ApplicationArea = All;
        }
      }
      group(MaterialAndPrint)
      {
        Caption = 'Material and Print';

        field("Material Code"; Rec."Material Code")
        {
          ApplicationArea = All;
        }
        field("Material GSM"; Rec."Material GSM")
        {
          ApplicationArea = All;
        }
        field("Print Process"; Rec."Print Process")
        {
          ApplicationArea = All;
        }
        field("No. of Colors"; Rec."No. of Colors")
        {
          ApplicationArea = All;
        }
        field(Lamination; Rec.Lamination)
        {
          ApplicationArea = All;
        }
        field("Die Cut"; Rec."Die Cut")
        {
          ApplicationArea = All;
        }
        field("Die Cost"; Rec."Die Cost")
        {
          ApplicationArea = All;
        }
        field("Waste %"; Rec."Waste %")
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
      action(CreateCostSheet)
      {
        ApplicationArea = All;
        Caption = 'Create Cost Sheet';
        Image = CalculateCost;
        ToolTip = 'Calculate the cost and price ladder of this specification on a new cost sheet.', Comment = 'hu-HU=Kiszámítja a specifikáció költségét és ársávjait egy új költséglapon.';

        trigger OnAction()
        var
          CostSheet: Record "CCO Packaging Cost Sheet";
          CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";
        begin
          CurrPage.SaveRecord();
          CostEngineMgt.CreateCostSheet(Rec."No.", CostSheet);
          Page.Run(Page::"CCO Packaging Cost Sheet", CostSheet);
        end;
      }
      action(CreateSalesQuote)
      {
        ApplicationArea = All;
        Caption = 'Create Sales Quote';
        Image = NewSalesQuote;
        ToolTip = 'Open the quote wizard for this specification to calculate the price ladder and create a sales quote.', Comment = 'hu-HU=Megnyitja az árajánlat-varázslót ehhez a specifikációhoz az ársávok kiszámításához és az értékesítési árajánlat létrehozásához.';

        trigger OnAction()
        var
          PackagingQuoteWizard: Page "CCO Packaging Quote Wizard";
        begin
          CurrPage.SaveRecord();
          PackagingQuoteWizard.SetSpecification(Rec);
          PackagingQuoteWizard.Run();
        end;
      }
      group(Production)
      {
        Caption = 'Production';
        Image = Production;

        action(GenerateProductionBOM)
        {
          ApplicationArea = All;
          Caption = 'Generate Production BOM';
          Image = BOM;
          ToolTip = 'Create or replace the certified production BOM of the finished item from the packaging BOM, and assign it to the item. The packaging BOM is calculated first if it does not exist yet.', Comment = 'hu-HU=Létrehozza vagy lecseréli a késztermék jóváhagyott gyártási darabjegyzékét a csomagolási darabjegyzék alapján, és hozzárendeli a cikkhez. Ha a csomagolási darabjegyzék még nem létezik, előbb kiszámítja.';

          trigger OnAction()
          var
            BOMGeneratorMgt: Codeunit "CCO BOM Generator Mgt.";
            ProductionBOMNo: Code[20];
          begin
            CurrPage.SaveRecord();
            ProductionBOMNo := BOMGeneratorMgt.GenerateProductionBOM(Rec);
            Message(ProductionBOMCreatedMsg, ProductionBOMNo);
          end;
        }
        action(GenerateRouting)
        {
          ApplicationArea = All;
          Caption = 'Generate Routing';
          Image = Route;
          ToolTip = 'Create or replace the certified routing of the finished item from the routing template, and assign it to the item. Only operations whose condition applies to this specification are included.', Comment = 'hu-HU=Létrehozza vagy lecseréli a késztermék jóváhagyott műveleti tervét a műveleti sablon alapján, és hozzárendeli a cikkhez. Csak azok a műveletek kerülnek bele, amelyek feltétele erre a specifikációra teljesül.';

          trigger OnAction()
          var
            RoutingGeneratorMgt: Codeunit "CCO Routing Generator Mgt.";
            RoutingNo: Code[20];
          begin
            CurrPage.SaveRecord();
            RoutingNo := RoutingGeneratorMgt.GenerateRouting(Rec);
            CurrPage.Update(false);
            Message(RoutingCreatedMsg, RoutingNo, Rec."Routing Template Code");
          end;
        }
      }
    }
    area(Navigation)
    {
      action(CostSheets)
      {
        ApplicationArea = All;
        Caption = 'Cost Sheets';
        Image = CostBudget;
        RunObject = page "CCO Packaging Cost Sheets";
        RunPageLink = "Specification No." = field("No.");
        ToolTip = 'View the cost sheets of this specification.', Comment = 'hu-HU=Megjeleníti a specifikáció költséglapjait.';
      }
      action(PackagingBOM)
      {
        ApplicationArea = All;
        Caption = 'Packaging BOM';
        Image = BOMLevel;
        ToolTip = 'View or edit the components of this specification. They are calculated from the specification the first time you open the packaging BOM.', Comment = 'hu-HU=Megjeleníti vagy szerkeszti a specifikáció összetevőit. Az összetevőket a csomagolási darabjegyzék első megnyitásakor számítja ki a specifikációból.';

        trigger OnAction()
        var
          PackagingBOM: Record "CCO Packaging BOM";
          BOMGeneratorMgt: Codeunit "CCO BOM Generator Mgt.";
        begin
          CurrPage.SaveRecord();
          if not PackagingBOM.Get(Rec."No.") then begin
            BOMGeneratorMgt.CalculatePackagingBOM(Rec);
            PackagingBOM.Get(Rec."No.");
          end;
          Page.Run(Page::"CCO Packaging BOM", PackagingBOM);
        end;
      }
      action(ProductionBOM)
      {
        ApplicationArea = All;
        Caption = 'Production BOM';
        Image = BOM;
        ToolTip = 'Open the production BOM of the finished item.', Comment = 'hu-HU=Megnyitja a késztermék gyártási darabjegyzékét.';

        trigger OnAction()
        var
          Item: Record Item;
          ProductionBOMHeader: Record "Production BOM Header";
        begin
          Rec.TestField("Item No.");
          Item.Get(Rec."Item No.");
          Item.TestField("Production BOM No.");
          ProductionBOMHeader.Get(Item."Production BOM No.");
          Page.Run(Page::"Production BOM", ProductionBOMHeader);
        end;
      }
      action(Routing)
      {
        ApplicationArea = All;
        Caption = 'Routing';
        Image = Route;
        ToolTip = 'Open the routing of the finished item.', Comment = 'hu-HU=Megnyitja a késztermék műveleti tervét.';

        trigger OnAction()
        var
          Item: Record Item;
          RoutingHeader: Record "Routing Header";
        begin
          Rec.TestField("Item No.");
          Item.Get(Rec."Item No.");
          Item.TestField("Routing No.");
          RoutingHeader.Get(Item."Routing No.");
          Page.Run(Page::Routing, RoutingHeader);
        end;
      }
    }
    area(Promoted)
    {
      actionref(CreateCostSheet_Promoted; CreateCostSheet)
      {
      }
      actionref(CreateSalesQuote_Promoted; CreateSalesQuote)
      {
      }
      actionref(CostSheets_Promoted; CostSheets)
      {
      }
      group(Category_Production)
      {
        Caption = 'Production';

        actionref(PackagingBOM_Promoted; PackagingBOM)
        {
        }
        actionref(GenerateProductionBOM_Promoted; GenerateProductionBOM)
        {
        }
        actionref(GenerateRouting_Promoted; GenerateRouting)
        {
        }
      }
    }
  }

  var
    ProductionBOMCreatedMsg: Label 'Production BOM %1 was generated, certified, and assigned to the finished item.', Comment = '%1 = Production BOM No.';
    RoutingCreatedMsg: Label 'Routing %1 was generated from routing template %2, certified, and assigned to the finished item.', Comment = '%1 = Routing No., %2 = Routing Template Code';
}
