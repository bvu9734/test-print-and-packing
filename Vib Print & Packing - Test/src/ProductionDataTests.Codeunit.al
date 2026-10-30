codeunit 50206 "CCO Production Data Tests"
{
  Subtype = Test;
  TestPermissions = Disabled;

  var
    Assert: Codeunit "Library Assert";
    LibraryPackaging: Codeunit "CCO Library - Packaging";
    BOMGeneratorMgt: Codeunit "CCO BOM Generator Mgt.";
    RoutingGeneratorMgt: Codeunit "CCO Routing Generator Mgt.";

  [Test]
  procedure CalculatePackagingBOMUsesSpecificationQuantities()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingSetup: Record "CCO Packaging Setup";
    PackagingBOMLine: Record "CCO Packaging BOM Line";
  begin
    // [GIVEN] A laminated 300 x 200 mm specification with 2 colors and 10% waste
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, '', true, true);
    PackagingSetup.Get();

    // [WHEN] The packaging BOM is calculated
    BOMGeneratorMgt.CalculatePackagingBOM(PackagingSpecification);

    // [THEN] Material, ink, glue, and film are components; quantities are per piece and the waste becomes scrap
    PackagingBOMLine.SetRange("Specification No.", PackagingSpecification."No.");
    Assert.RecordCount(PackagingBOMLine, 4);
    VerifyPackagingBOMLine(PackagingSpecification."No.", PackagingSpecification."Material Code", 0.06, 10);
    VerifyPackagingBOMLine(PackagingSpecification."No.", PackagingSetup."Ink Item No.", 0.0012, 10);
    VerifyPackagingBOMLine(PackagingSpecification."No.", PackagingSetup."Glue Item No.", 0.005, 0);
    VerifyPackagingBOMLine(PackagingSpecification."No.", PackagingSetup."Lamination Film Item No.", 0.06, 10);
  end;

  [Test]
  procedure CalculatePackagingBOMSkipsFilmWithoutLamination()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingSetup: Record "CCO Packaging Setup";
    PackagingBOMLine: Record "CCO Packaging BOM Line";
  begin
    // [GIVEN] A specification without lamination
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, '', false, false);
    PackagingSetup.Get();

    // [WHEN] The packaging BOM is calculated
    BOMGeneratorMgt.CalculatePackagingBOM(PackagingSpecification);

    // [THEN] No film component is added
    PackagingBOMLine.SetRange("Specification No.", PackagingSpecification."No.");
    Assert.RecordCount(PackagingBOMLine, 3);
    PackagingBOMLine.SetRange("Item No.", PackagingSetup."Lamination Film Item No.");
    Assert.RecordIsEmpty(PackagingBOMLine);
  end;

  [Test]
  procedure GenerateProductionBOMCreatesCertifiedBOM()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingBOM: Record "CCO Packaging BOM";
    ProductionBOMHeader: Record "Production BOM Header";
    ProductionBOMLine: Record "Production BOM Line";
    Item: Record Item;
    ProductionBOMNo: Code[20];
  begin
    // [GIVEN] A released, laminated specification with a finished item
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, '', true, true);

    // [WHEN] The production BOM is generated
    ProductionBOMNo := BOMGeneratorMgt.GenerateProductionBOM(PackagingSpecification);

    // [THEN] A certified production BOM with the item number and four components is assigned to the finished item
    Item.Get(PackagingSpecification."Item No.");
    Assert.AreEqual(Item."No.", ProductionBOMNo, 'The production BOM must have the number of the finished item.');
    ProductionBOMHeader.Get(ProductionBOMNo);
    Assert.AreEqual(ProductionBOMHeader.Status::Certified, ProductionBOMHeader.Status, 'The production BOM must be certified.');
    Assert.AreEqual(Item."Base Unit of Measure", ProductionBOMHeader."Unit of Measure Code", 'The production BOM must use the base unit of the item.');
    Assert.AreEqual(ProductionBOMNo, Item."Production BOM No.", 'The production BOM must be assigned to the finished item.');

    ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMNo);
    Assert.RecordCount(ProductionBOMLine, 4);
    ProductionBOMLine.SetRange("No.", PackagingSpecification."Material Code");
    ProductionBOMLine.FindFirst();
    AssertDecimal(0.06, ProductionBOMLine."Quantity per", 'The material quantity per piece must be the base area.');
    AssertDecimal(10, ProductionBOMLine."Scrap %", 'The waste of the specification must become the scrap of the material.');

    PackagingBOM.Get(PackagingSpecification."No.");
    Assert.AreEqual(ProductionBOMNo, PackagingBOM."Production BOM No.", 'The packaging BOM must show the generated production BOM.');
  end;

  [Test]
  procedure RegenerateProductionBOMReplacesLines()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    ProductionBOMHeader: Record "Production BOM Header";
    ProductionBOMLine: Record "Production BOM Line";
    ProductionBOMNo: Code[20];
  begin
    // [GIVEN] A generated production BOM
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, '', true, true);
    BOMGeneratorMgt.GenerateProductionBOM(PackagingSpecification);

    // [WHEN] The waste changes to 20% and the BOM is recalculated and generated again
    PackagingSpecification.Get(PackagingSpecification."No.");
    PackagingSpecification."Waste %" := 20;
    PackagingSpecification.Modify(false);
    BOMGeneratorMgt.CalculatePackagingBOM(PackagingSpecification);
    ProductionBOMNo := BOMGeneratorMgt.GenerateProductionBOM(PackagingSpecification);

    // [THEN] The lines are replaced and the BOM is certified again
    ProductionBOMHeader.Get(ProductionBOMNo);
    Assert.AreEqual(ProductionBOMHeader.Status::Certified, ProductionBOMHeader.Status, 'The production BOM must be certified again.');
    ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMNo);
    Assert.RecordCount(ProductionBOMLine, 4);
    ProductionBOMLine.SetRange("No.", PackagingSpecification."Material Code");
    ProductionBOMLine.FindFirst();
    AssertDecimal(20, ProductionBOMLine."Scrap %", 'The new waste must be used.');
  end;

  [Test]
  procedure RegenerateProductionBOMUsedByOpenProdOrderFails()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    ProdOrderLine: Record "Prod. Order Line";
    ProductionBOMNo: Code[20];
  begin
    // [GIVEN] A generated production BOM that is used by a released production order
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, '', false, false);
    ProductionBOMNo := BOMGeneratorMgt.GenerateProductionBOM(PackagingSpecification);
    ProdOrderLine.Init();
    ProdOrderLine.Status := ProdOrderLine.Status::Released;
    ProdOrderLine."Prod. Order No." := LibraryPackaging.NewCode();
    ProdOrderLine."Line No." := 10000;
    ProdOrderLine."Item No." := PackagingSpecification."Item No.";
    ProdOrderLine."Production BOM No." := ProductionBOMNo;
    ProdOrderLine.Insert(false);

    // [WHEN] The production BOM is generated again
    asserterror BOMGeneratorMgt.GenerateProductionBOM(PackagingSpecification);

    // [THEN] The BOM is not replaced
    Assert.ExpectedError('is used by an open production order');
  end;

  [Test]
  procedure GenerateRoutingIncludesApplicableOperations()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    RoutingHeader: Record "Routing Header";
    RoutingLine: Record "Routing Line";
    Item: Record Item;
    RoutingNo: Code[20];
  begin
    // [GIVEN] A printed, die-cut specification without lamination, and a template with print, laminate, die cut, and pack operations
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, '', true, false);
    PackagingSpecification."Routing Template Code" := LibraryPackaging.CreateRoutingTemplate();
    PackagingSpecification.Modify(false);

    // [WHEN] The routing is generated
    RoutingNo := RoutingGeneratorMgt.GenerateRouting(PackagingSpecification);

    // [THEN] A certified routing with print, die cut, and pack operations is assigned to the finished item
    Item.Get(PackagingSpecification."Item No.");
    Assert.AreEqual(Item."No.", RoutingNo, 'The routing must have the number of the finished item.');
    Assert.AreEqual(RoutingNo, Item."Routing No.", 'The routing must be assigned to the finished item.');
    RoutingHeader.Get(RoutingNo);
    Assert.AreEqual(RoutingHeader.Status::Certified, RoutingHeader.Status, 'The routing must be certified.');
    VerifyOperations(RoutingNo, '10|30|40', 3);
    RoutingLine.Get(RoutingNo, '', '30');
    AssertDecimal(45, RoutingLine."Setup Time", 'The setup time must come from the template.');
    AssertDecimal(0.015, RoutingLine."Run Time", 'The run time must come from the template.');
  end;

  [Test]
  procedure RegenerateRoutingReplacesOperations()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    RoutingNo: Code[20];
  begin
    // [GIVEN] A routing generated for a die-cut specification
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, '', true, false);
    PackagingSpecification."Routing Template Code" := LibraryPackaging.CreateRoutingTemplate();
    PackagingSpecification.Modify(false);
    RoutingGeneratorMgt.GenerateRouting(PackagingSpecification);

    // [WHEN] Die cutting is removed and the routing is generated again
    PackagingSpecification."Die Cut" := false;
    PackagingSpecification.Modify(false);
    RoutingNo := RoutingGeneratorMgt.GenerateRouting(PackagingSpecification);

    // [THEN] The die cutting operation is gone
    VerifyOperations(RoutingNo, '10|40', 2);
  end;

  [Test]
  procedure RoutingTemplateDefaultsByRule()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingSetup: Record "CCO Packaging Setup";
  begin
    // [GIVEN] Default digital, box, and label templates in Packaging Setup
    LibraryPackaging.InitializeRates();
    PackagingSetup.Get();
    PackagingSetup."Digital Routing Template" := 'T-DIGITAL';
    PackagingSetup."Box Routing Template" := 'T-BOX';
    PackagingSetup."Label Routing Template" := 'T-LABEL';
    PackagingSetup.Modify(false);
    LibraryPackaging.CreateSpecification(PackagingSpecification, '', true, false);

    // [THEN] Digital printing uses the digital template, even when die cut
    PackagingSpecification."Print Process" := PackagingSpecification."Print Process"::Digital;
    Assert.AreEqual('T-DIGITAL', RoutingGeneratorMgt.GetRoutingTemplateCode(PackagingSpecification), 'Digital printing must use the digital template.');

    // [THEN] Other die-cut products use the box template
    PackagingSpecification."Print Process" := PackagingSpecification."Print Process"::Offset;
    Assert.AreEqual('T-BOX', RoutingGeneratorMgt.GetRoutingTemplateCode(PackagingSpecification), 'Die-cut products must use the box template.');

    // [THEN] Everything else uses the label template
    PackagingSpecification."Die Cut" := false;
    Assert.AreEqual('T-LABEL', RoutingGeneratorMgt.GetRoutingTemplateCode(PackagingSpecification), 'Other products must use the label template.');

    // [THEN] A template on the specification overrides the defaults
    PackagingSpecification."Routing Template Code" := 'T-OWN';
    Assert.AreEqual('T-OWN', RoutingGeneratorMgt.GetRoutingTemplateCode(PackagingSpecification), 'The template on the specification must win.');
  end;

  local procedure VerifyPackagingBOMLine(SpecificationNo: Code[20]; ItemNo: Code[20]; ExpectedQuantityPer: Decimal; ExpectedScrapPercent: Decimal)
  var
    PackagingBOMLine: Record "CCO Packaging BOM Line";
  begin
    PackagingBOMLine.SetRange("Specification No.", SpecificationNo);
    PackagingBOMLine.SetRange("Item No.", ItemNo);
    PackagingBOMLine.FindFirst();
    AssertDecimal(ExpectedQuantityPer, PackagingBOMLine."Quantity per", 'Quantity per of ' + ItemNo);
    AssertDecimal(ExpectedScrapPercent, PackagingBOMLine."Scrap %", 'Scrap % of ' + ItemNo);
  end;

  local procedure VerifyOperations(RoutingNo: Code[20]; OperationFilter: Text; ExpectedCount: Integer)
  var
    RoutingLine: Record "Routing Line";
  begin
    RoutingLine.SetRange("Routing No.", RoutingNo);
    RoutingLine.SetRange("Version Code", '');
    Assert.RecordCount(RoutingLine, ExpectedCount);
    RoutingLine.SetFilter("Operation No.", OperationFilter);
    Assert.RecordCount(RoutingLine, ExpectedCount);
  end;

  local procedure AssertDecimal(Expected: Decimal; Actual: Decimal; Message: Text)
  begin
    Assert.AreEqual(Expected, Actual, Message);
  end;
}
