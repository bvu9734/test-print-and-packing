page 50146 "CCO Packaging BOM"
{
  Caption = 'Packaging BOM';
  PageType = Document;
  SourceTable = "CCO Packaging BOM";
  ApplicationArea = All;
  InsertAllowed = false;

  layout
  {
    area(Content)
    {
      group(General)
      {
        Caption = 'General';

        field("Specification No."; Rec."Specification No.")
        {
          ApplicationArea = All;
          Editable = false;
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
        }
        field("Calculation Date"; Rec."Calculation Date")
        {
          ApplicationArea = All;
        }
        field("Production BOM No."; Rec."Production BOM No.")
        {
          ApplicationArea = All;
        }
      }
      part(Lines; "CCO Packaging BOM Subform")
      {
        ApplicationArea = All;
        Caption = 'Components';
        SubPageLink = "Specification No." = field("Specification No.");
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(CalculateFromSpecification)
      {
        ApplicationArea = All;
        Caption = 'Calculate from Specification';
        Image = Calculate;
        ToolTip = 'Recalculate the components from the specification and the consumption settings. Manual changes to the components are replaced.', Comment = 'hu-HU=Újraszámítja az összetevőket a specifikáció és a felhasználási beállítások alapján. Az összetevők kézi módosításai felülíródnak.';

        trigger OnAction()
        var
          PackagingSpecification: Record "CCO Packaging Specification";
          BOMGeneratorMgt: Codeunit "CCO BOM Generator Mgt.";
        begin
          if not Confirm(RecalculateQst, false) then
            exit;
          CurrPage.SaveRecord();
          PackagingSpecification.Get(Rec."Specification No.");
          BOMGeneratorMgt.CalculatePackagingBOM(PackagingSpecification);
          CurrPage.Update(false);
        end;
      }
      action(GenerateProductionBOM)
      {
        ApplicationArea = All;
        Caption = 'Generate Production BOM';
        Image = BOM;
        ToolTip = 'Create or replace the certified production BOM of the finished item from these components, and assign it to the item.', Comment = 'hu-HU=Létrehozza vagy lecseréli a késztermék jóváhagyott gyártási darabjegyzékét ezekből az összetevőkből, és hozzárendeli a cikkhez.';

        trigger OnAction()
        var
          PackagingSpecification: Record "CCO Packaging Specification";
          BOMGeneratorMgt: Codeunit "CCO BOM Generator Mgt.";
          ProductionBOMNo: Code[20];
        begin
          CurrPage.SaveRecord();
          PackagingSpecification.Get(Rec."Specification No.");
          ProductionBOMNo := BOMGeneratorMgt.GenerateProductionBOM(PackagingSpecification);
          CurrPage.Update(false);
          Message(ProductionBOMCreatedMsg, ProductionBOMNo);
        end;
      }
    }
    area(Navigation)
    {
      action(Specification)
      {
        ApplicationArea = All;
        Caption = 'Specification';
        Image = Document;
        RunObject = page "CCO Packaging Spec. Card";
        RunPageLink = "No." = field("Specification No.");
        ToolTip = 'Open the packaging specification.', Comment = 'hu-HU=Megnyitja a csomagolási specifikációt.';
      }
      action(ProductionBOM)
      {
        ApplicationArea = All;
        Caption = 'Production BOM';
        Enabled = Rec."Production BOM No." <> '';
        Image = BOM;
        RunObject = page "Production BOM";
        RunPageLink = "No." = field("Production BOM No.");
        ToolTip = 'Open the production BOM that was generated from this packaging BOM.', Comment = 'hu-HU=Megnyitja a csomagolási darabjegyzékből generált gyártási darabjegyzéket.';
      }
    }
    area(Promoted)
    {
      actionref(CalculateFromSpecification_Promoted; CalculateFromSpecification)
      {
      }
      actionref(GenerateProductionBOM_Promoted; GenerateProductionBOM)
      {
      }
      actionref(ProductionBOM_Promoted; ProductionBOM)
      {
      }
    }
  }

  var
    RecalculateQst: Label 'The components are recalculated from the specification, and manual changes are replaced. Do you want to continue?';
    ProductionBOMCreatedMsg: Label 'Production BOM %1 was generated, certified, and assigned to the finished item.', Comment = '%1 = Production BOM No.';
}
