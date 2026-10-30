codeunit 50205 "CCO Packaging Demo Data Tests"
{
  Subtype = Test;
  TestPermissions = Disabled;

  var
    Assert: Codeunit "Library Assert";
    PackagingDemoData: Codeunit "CCO Packaging Demo Data";

  [Test]
  procedure GenerateCreatesCompleteDemoData()
  var
    Item: Record Item;
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    PrintCostMatrix: Record "CCO Print Cost Matrix";
    PackagingSetup: Record "CCO Packaging Setup";
    WorkCenter: Record "Work Center";
    RoutingTemplateLine: Record "CCO Routing Template Line";
    MaterialTypeOrdinal: Integer;
    MaterialType: Enum "CCO Material Type";
  begin
    // [WHEN] Demo data is generated
    PackagingDemoData.Generate();

    // [THEN] An item exists for every packaging material type
    foreach MaterialTypeOrdinal in "CCO Material Type".Ordinals() do begin
      MaterialType := "CCO Material Type".FromInteger(MaterialTypeOrdinal);
      if MaterialType <> MaterialType::None then begin
        Item.SetRange("CCO Packaging Material Type", MaterialType);
        Assert.RecordIsNotEmpty(Item);
      end;
    end;

    // [THEN] The setup, print rates, specifications, and worksheet are ready for a manual test
    PackagingSetup.Get();
    PackagingSetup.TestField("Item Nos.");
    PackagingSetup.TestField("Cost Sheet Nos.");
    PackagingSetup.TestField("Ink Item No.");
    Assert.AreEqual(4, PrintCostMatrix.Count(), 'All four print processes must have rates.');

    PackagingSpecification.Get('PP-DEMO-BOX');
    Assert.AreNotEqual('', PackagingSpecification."Item No.", 'Released demo specifications must have a finished item.');
    PackagingSpecification.Get('PP-DEMO-DRAFT');
    Assert.AreEqual(PackagingSpecification.Status::Draft, PackagingSpecification.Status, 'The draft demo specification must stay a draft.');

    PackagingWkshLine.SetRange("Worksheet Name", 'DEMO');
    Assert.RecordCount(PackagingWkshLine, 4);
    PackagingWkshLine.SetRange("Unit Price (LCY)", 0);
    Assert.RecordIsEmpty(PackagingWkshLine);

    // [THEN] Work centers and routing templates for production are available
    Assert.IsTrue(WorkCenter.Get('PP-PRINT'), 'The printing work center must exist.');
    RoutingTemplateLine.SetRange("Template Code", 'BOX_STD');
    Assert.RecordCount(RoutingTemplateLine, 6);
    PackagingSetup.TestField("Box Routing Template");
  end;

  [Test]
  procedure GenerateTwiceKeepsExistingRecords()
  var
    Item: Record Item;
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    ItemCount: Integer;
    SpecificationCount: Integer;
    CorrugatedCost: Decimal;
  begin
    // [GIVEN] Demo data was generated once
    PackagingDemoData.Generate();
    ItemCount := Item.Count();
    SpecificationCount := PackagingSpecification.Count();
    Item.Get('PP-CORRUGATED');
    CorrugatedCost := Item."CCO Cost per m²";

    // [WHEN] It is generated again
    PackagingDemoData.Generate();

    // [THEN] No records are added and existing values are kept
    Assert.AreEqual(ItemCount, Item.Count(), 'No items must be added on the second run.');
    Assert.AreEqual(SpecificationCount, PackagingSpecification.Count(), 'No specifications must be added on the second run.');
    Item.Get('PP-CORRUGATED');
    Assert.AreEqual(CorrugatedCost, Item."CCO Cost per m²", 'Existing material costs must be kept.');
    PackagingWkshLine.SetRange("Worksheet Name", 'DEMO');
    Assert.RecordCount(PackagingWkshLine, 4);
  end;
}
