codeunit 50207 "CCO Packaging Production Tests"
{
  Subtype = Test;
  TestPermissions = Disabled;

  var
    Assert: Codeunit "Library Assert";
    LibraryPackaging: Codeunit "CCO Library - Packaging";
    PackagingProductionMgt: Codeunit "CCO Packaging Production Mgt.";
    NotificationMessage: Text;

  [Test]
  procedure CreatesFirmPlannedProdOrderForSalesLine()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
    Item: Record Item;
  begin
    // [GIVEN] Setup with Firm Planned status and a sales order line for 1,000 pieces of a specification without production BOM and routing
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Warning);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);

    // [WHEN] Packaging production is created for the line
    Assert.IsTrue(PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder), 'A production order must be created.');

    // [THEN] A firm planned order for the item, quantity, and shipment date of the line is created
    Assert.AreEqual(ProductionOrder.Status::"Firm Planned", ProductionOrder.Status, 'Status');
    Assert.AreEqual(ProductionOrder."Source Type"::Item, ProductionOrder."Source Type", 'Source Type');
    Assert.AreEqual(SalesLine."No.", ProductionOrder."Source No.", 'Source No.');
    AssertDecimal(1000, ProductionOrder.Quantity, 'Quantity');
    Assert.AreEqual(SalesLine."Shipment Date", ProductionOrder."Due Date", 'Due Date');

    // [THEN] The production BOM and routing were generated and assigned to the item
    Item.Get(SalesLine."No.");
    Assert.AreEqual(Item."No.", Item."Production BOM No.", 'Production BOM No. of the item');
    Assert.AreEqual(Item."No.", Item."Routing No.", 'Routing No. of the item');

    // [THEN] The order has the four components and the four applicable operations
    VerifyComponentCount(ProductionOrder, 4);
    VerifyRoutingLineCount(ProductionOrder, 4);
  end;

  [Test]
  procedure ProdOrderComponentsIncludeScrap()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
    ProdOrderComponent: Record "Prod. Order Component";
  begin
    // [GIVEN] A sales order line for 1,000 pieces of a 300 x 200 mm specification with 10% waste
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Warning);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);

    // [WHEN] Packaging production is created for the line
    PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);

    // [THEN] The material component expects 1,000 x 0.06 m² plus 10% scrap = 66 m²
    ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
    ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
    ProdOrderComponent.SetRange("Item No.", PackagingSpecification."Material Code");
    ProdOrderComponent.FindFirst();
    AssertDecimal(66, ProdOrderComponent."Expected Quantity", 'Expected quantity of the material');
  end;

  [Test]
  procedure CreatesReleasedProdOrderWhenSetUp()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
  begin
    // [GIVEN] Setup with Released status
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::Released, "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Warning);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 500);

    // [WHEN] Packaging production is created for the line
    PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);

    // [THEN] The production order is released
    Assert.AreEqual(ProductionOrder.Status::Released, ProductionOrder.Status, 'Status');
  end;

  [Test]
  procedure ProdOrderIsLinkedToSalesLine()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
  begin
    // [GIVEN] A packaging sales order line with a cost sheet number
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Warning);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);
    SalesLine."CCO Cost Sheet No." := 'CS-TEST';
    SalesLine.Modify(false);

    // [WHEN] Packaging production is created for the line
    PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);

    // [THEN] The production order holds the sales order line, specification, and cost sheet
    Assert.AreEqual(SalesLine."Document No.", ProductionOrder."CCO Sales Order No.", 'Sales Order No.');
    Assert.AreEqual(SalesLine."Line No.", ProductionOrder."CCO Sales Order Line No.", 'Sales Order Line No.');
    Assert.AreEqual(PackagingSpecification."No.", ProductionOrder."CCO Packaging Spec. No.", 'Packaging Spec. No.');
    Assert.AreEqual('CS-TEST', ProductionOrder."CCO Cost Sheet No.", 'Cost Sheet No.');

    // [THEN] The sales line shows the production order
    SalesLine.Find();
    SalesLine.CalcFields("CCO Prod. Order No.");
    Assert.AreEqual(ProductionOrder."No.", SalesLine."CCO Prod. Order No.", 'Prod. Order No. on the sales line');
  end;

  [Test]
  procedure SecondRunDoesNotCreateDuplicate()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
    ExistingProductionOrder: Record "Production Order";
  begin
    // [GIVEN] A sales order line that already has a production order
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Warning);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);
    PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);

    // [WHEN] Packaging production is created again
    Assert.IsFalse(PackagingProductionMgt.CreatePackagingProduction(SalesLine, ExistingProductionOrder), 'No second production order may be created.');

    // [THEN] The existing order is returned and only one order exists for the line
    Assert.AreEqual(ProductionOrder."No.", ExistingProductionOrder."No.", 'The existing production order must be returned.');
    ProductionOrder.Reset();
    ProductionOrder.SetRange("CCO Sales Order No.", SalesLine."Document No.");
    ProductionOrder.SetRange("CCO Sales Order Line No.", SalesLine."Line No.");
    Assert.RecordCount(ProductionOrder, 1);
  end;

  [Test]
  procedure OnlyIfMissingKeepsExistingProductionBOM()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
  begin
    // [GIVEN] Setup Only if Missing, a generated production BOM, and a later change of the packaging BOM
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Warning);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);
    GenerateProductionBOMAndChangeMaterial(PackagingSpecification, 0.1);

    // [WHEN] Packaging production is created
    PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);

    // [THEN] The existing production BOM is used unchanged
    VerifyProductionBOMQuantityPer(PackagingSpecification, 0.06);
  end;

  [Test]
  procedure AlwaysRegenerateUsesCurrentPackagingBOM()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
  begin
    // [GIVEN] Setup Always Regenerate, a generated production BOM, and a later change of the packaging BOM
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Always Regenerate", "CCO Prod. Order Qty. Check"::Warning);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);
    GenerateProductionBOMAndChangeMaterial(PackagingSpecification, 0.1);

    // [WHEN] Packaging production is created
    PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);

    // [THEN] The production BOM is generated again from the changed packaging BOM
    VerifyProductionBOMQuantityPer(PackagingSpecification, 0.1);
  end;

  [Test]
  procedure SpecificationNotReleasedFails()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
  begin
    // [GIVEN] A packaging sales order line whose specification is set back to draft
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Warning);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);
    PackagingSpecification.Status := PackagingSpecification.Status::Draft;
    PackagingSpecification.Modify(false);

    // [WHEN] Packaging production is created
    asserterror PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);

    // [THEN] An error says that the specification must be released, and no production order exists
    Assert.ExpectedError('must be released');
    VerifyNoProdOrderForLine(SalesLine);
  end;

  [Test]
  procedure LineWithoutSpecificationFails()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
  begin
    // [GIVEN] A sales order line without a packaging specification
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);
    SalesLine."CCO Packaging Spec. No." := '';
    SalesLine.Modify(false);

    // [WHEN] Packaging production is created
    asserterror PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);

    // [THEN] An error says that the line has no packaging specification
    Assert.ExpectedError('has no packaging specification');
  end;

  [Test]
  [HandlerFunctions('QtyChangedNotificationHandler,CheckProdOrderStatusHandler')]
  procedure QtyChangeWithWarningSendsNotification()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
  begin
    // [GIVEN] Setup Warning and a sales order line with a production order
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Warning);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);
    PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);
    NotificationMessage := '';
    SetPlanningWarning(true);

    // [WHEN] The quantity of the sales line is changed and the standard production order warning is confirmed
    SalesLine.Find();
    SalesLine.Validate(Quantity, 1200);

    // [THEN] The change is allowed and a notification names the production order
    AssertDecimal(1200, SalesLine.Quantity, 'Quantity');
    Assert.IsTrue(StrPos(NotificationMessage, ProductionOrder."No.") > 0, 'The notification must name the production order.');
  end;

  [Test]
  procedure QtyChangeWithErrorIsBlocked()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
    ProductionOrder: Record "Production Order";
  begin
    // [GIVEN] Setup Error, Planning Warning on, and a sales order line with a production order
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Error);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);
    PackagingProductionMgt.CreatePackagingProduction(SalesLine, ProductionOrder);
    SetPlanningWarning(true);

    // [WHEN] The quantity of the sales line is changed
    SalesLine.Find();
    asserterror SalesLine.Validate(Quantity, 1200);

    // [THEN] The change is blocked before the standard warning, with an error that names the production order
    Assert.ExpectedError(ProductionOrder."No.");
    Assert.ExpectedError('Change or delete the production order first');
  end;

  [Test]
  procedure QtyChangeWithoutProdOrderIsNotChecked()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    SalesLine: Record "Sales Line";
  begin
    // [GIVEN] Setup Error and a sales order line without a production order
    LibraryPackaging.InitializeRates();
    LibraryPackaging.SetProductionSetup("CCO Pack. Prod. Order Status"::"Firm Planned", "CCO BOM Routing Generation"::"Only if Missing", "CCO Prod. Order Qty. Check"::Error);
    LibraryPackaging.CreatePackagingSalesOrder(PackagingSpecification, SalesLine, 1000);

    // [WHEN] The quantity of the sales line is changed
    SalesLine.Validate(Quantity, 1200);

    // [THEN] The change is allowed
    AssertDecimal(1200, SalesLine.Quantity, 'Quantity');
  end;

  [SendNotificationHandler]
  procedure QtyChangedNotificationHandler(var QtyChangedNotification: Notification): Boolean
  begin
    NotificationMessage := QtyChangedNotification.Message;
  end;

  [ModalPageHandler]
  procedure CheckProdOrderStatusHandler(var CheckProdOrderStatus: TestPage "Check Prod. Order Status")
  begin
    // Standard Business Central asks for confirmation when the line is reserved against a production order and Planning Warning is on.
    CheckProdOrderStatus.Yes().Invoke();
  end;

  local procedure SetPlanningWarning(PlanningWarning: Boolean)
  var
    ManufacturingSetup: Record "Manufacturing Setup";
  begin
    ManufacturingSetup.Get();
    ManufacturingSetup."Planning Warning" := PlanningWarning;
    ManufacturingSetup.Modify(false);
  end;

  local procedure GenerateProductionBOMAndChangeMaterial(PackagingSpecification: Record "CCO Packaging Specification"; NewQuantityPer: Decimal)
  var
    PackagingBOMLine: Record "CCO Packaging BOM Line";
    BOMGeneratorMgt: Codeunit "CCO BOM Generator Mgt.";
  begin
    BOMGeneratorMgt.GenerateProductionBOM(PackagingSpecification);
    PackagingBOMLine.SetRange("Specification No.", PackagingSpecification."No.");
    PackagingBOMLine.SetRange("Item No.", PackagingSpecification."Material Code");
    PackagingBOMLine.FindFirst();
    PackagingBOMLine.Validate("Quantity per", NewQuantityPer);
    PackagingBOMLine.Modify(true);
  end;

  local procedure VerifyProductionBOMQuantityPer(PackagingSpecification: Record "CCO Packaging Specification"; ExpectedQuantityPer: Decimal)
  var
    ProductionBOMLine: Record "Production BOM Line";
  begin
    ProductionBOMLine.SetRange("Production BOM No.", PackagingSpecification."Item No.");
    ProductionBOMLine.SetRange("Version Code", '');
    ProductionBOMLine.SetRange("No.", PackagingSpecification."Material Code");
    ProductionBOMLine.FindFirst();
    AssertDecimal(ExpectedQuantityPer, ProductionBOMLine."Quantity per", 'Quantity per of the material in the production BOM');
  end;

  local procedure VerifyComponentCount(ProductionOrder: Record "Production Order"; ExpectedCount: Integer)
  var
    ProdOrderComponent: Record "Prod. Order Component";
  begin
    ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
    ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
    Assert.RecordCount(ProdOrderComponent, ExpectedCount);
  end;

  local procedure VerifyRoutingLineCount(ProductionOrder: Record "Production Order"; ExpectedCount: Integer)
  var
    ProdOrderRoutingLine: Record "Prod. Order Routing Line";
  begin
    ProdOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
    ProdOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
    Assert.RecordCount(ProdOrderRoutingLine, ExpectedCount);
  end;

  local procedure VerifyNoProdOrderForLine(SalesLine: Record "Sales Line")
  var
    ProductionOrder: Record "Production Order";
  begin
    ProductionOrder.SetRange("CCO Sales Order No.", SalesLine."Document No.");
    ProductionOrder.SetRange("CCO Sales Order Line No.", SalesLine."Line No.");
    Assert.RecordIsEmpty(ProductionOrder);
  end;

  local procedure AssertDecimal(Expected: Decimal; Actual: Decimal; Message: Text)
  begin
    Assert.AreEqual(Expected, Actual, Message);
  end;
}
