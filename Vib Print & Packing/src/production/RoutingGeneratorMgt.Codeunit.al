codeunit 50109 "CCO Routing Generator Mgt."
{
  var
    RoutingInUseErr: Label 'Routing %1 is used by an open production order and cannot be replaced. Finish or delete the production order, or create a new version of the routing manually.', Comment = '%1 = Routing No.';
    NoRoutingTemplateErr: Label 'No routing template is set for packaging specification %1. Enter a routing template on the specification, or set the default routing templates in Packaging Setup.', Comment = '%1 = Packaging Specification No.';
    NoOperationsErr: Label 'Routing template %1 has no operations that apply to packaging specification %2.', Comment = '%1 = Routing Template Code, %2 = Packaging Specification No.';

  /// <summary>
  /// Returns the routing template of a specification: the template entered on the specification, or otherwise the default from
  /// Packaging Setup — the digital template for digital printing, the box template for die-cut products, and the label template for all others.
  /// </summary>
  /// <param name="PackagingSpecification">The specification.</param>
  /// <returns>The routing template code, or blank when no template applies.</returns>
  procedure GetRoutingTemplateCode(PackagingSpecification: Record "CCO Packaging Specification") TemplateCode: Code[20]
  var
    PackagingSetup: Record "CCO Packaging Setup";
  begin
    TemplateCode := PackagingSpecification."Routing Template Code";
    if TemplateCode <> '' then
      exit;
    if not PackagingSetup.Get() then
      exit;

    if PackagingSpecification."Print Process" = PackagingSpecification."Print Process"::Digital then
      TemplateCode := PackagingSetup."Digital Routing Template";
    if (TemplateCode = '') and PackagingSpecification."Die Cut" then
      TemplateCode := PackagingSetup."Box Routing Template";
    if TemplateCode = '' then
      TemplateCode := PackagingSetup."Label Routing Template";
  end;

  /// <summary>
  /// Creates or replaces the certified routing of the finished item from the routing template of the specification, and assigns it to the item.
  /// Only operations whose condition applies to the specification are included. The routing has the number of the finished item.
  /// The applied template is saved on the specification.
  /// </summary>
  /// <param name="PackagingSpecification">The released specification. It is modified in the database.</param>
  /// <returns>The number of the routing.</returns>
  procedure GenerateRouting(var PackagingSpecification: Record "CCO Packaging Specification") RoutingNo: Code[20]
  var
    RoutingTemplate: Record "CCO Routing Template";
    RoutingTemplateLine: Record "CCO Routing Template Line";
    RoutingHeader: Record "Routing Header";
    Item: Record Item;
    TemplateCode: Code[20];
    OperationCount: Integer;
  begin
    PackagingSpecification.TestField("Item No.");
    Item.Get(PackagingSpecification."Item No.");

    TemplateCode := GetRoutingTemplateCode(PackagingSpecification);
    if TemplateCode = '' then
      Error(NoRoutingTemplateErr, PackagingSpecification."No.");
    RoutingTemplate.Get(TemplateCode);

    RoutingNo := Item."No.";
    PrepareRoutingHeader(RoutingHeader, RoutingNo, PackagingSpecification.Description);

    RoutingTemplateLine.SetRange("Template Code", TemplateCode);
    if RoutingTemplateLine.FindSet() then
      repeat
        if ConditionApplies(RoutingTemplateLine.Condition, PackagingSpecification) then begin
          InsertRoutingLine(RoutingNo, RoutingTemplateLine);
          OperationCount += 1;
        end;
      until RoutingTemplateLine.Next() = 0;
    if OperationCount = 0 then
      Error(NoOperationsErr, TemplateCode, PackagingSpecification."No.");

    RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
    RoutingHeader.Modify(true);

    if Item."Routing No." <> RoutingNo then begin
      Item.Validate("Routing No.", RoutingNo);
      Item.Modify(true);
    end;

    if PackagingSpecification."Routing Template Code" <> TemplateCode then begin
      PackagingSpecification."Routing Template Code" := TemplateCode;
      PackagingSpecification.Modify(true);
    end;
  end;

  /// <summary>
  /// Returns whether an operation with the given condition is included for the specification.
  /// </summary>
  /// <param name="Condition">The condition of the template operation.</param>
  /// <param name="PackagingSpecification">The specification.</param>
  /// <returns>True when the operation applies.</returns>
  procedure ConditionApplies(Condition: Enum "CCO Operation Condition"; PackagingSpecification: Record "CCO Packaging Specification") Applies: Boolean
  begin
    case Condition of
      Condition::Always:
        Applies := true;
      Condition::"Die Cut":
        Applies := PackagingSpecification."Die Cut";
      Condition::Lamination:
        Applies := PackagingSpecification.Lamination;
      Condition::Printing:
        Applies := PackagingSpecification."No. of Colors" > 0;
    end;
  end;

  local procedure PrepareRoutingHeader(var RoutingHeader: Record "Routing Header"; RoutingNo: Code[20]; RoutingDescription: Text[100])
  var
    RoutingLine: Record "Routing Line";
  begin
    if RoutingHeader.Get(RoutingNo) then begin
      CheckNotUsedByOpenProdOrder(RoutingNo);
      if RoutingHeader.Status <> RoutingHeader.Status::"Under Development" then begin
        RoutingHeader.Validate(Status, RoutingHeader.Status::"Under Development");
        RoutingHeader.Modify(true);
      end;
      RoutingLine.SetRange("Routing No.", RoutingNo);
      RoutingLine.SetRange("Version Code", '');
      RoutingLine.DeleteAll(true);
    end else begin
      RoutingHeader.Init();
      RoutingHeader."No." := RoutingNo;
      RoutingHeader.Insert(true);
      RoutingHeader.Validate(Type, RoutingHeader.Type::Serial);
    end;

    RoutingHeader.Validate(Description, RoutingDescription);
    RoutingHeader.Modify(true);
  end;

  local procedure InsertRoutingLine(RoutingNo: Code[20]; RoutingTemplateLine: Record "CCO Routing Template Line")
  var
    RoutingLine: Record "Routing Line";
  begin
    RoutingLine.Init();
    RoutingLine."Routing No." := RoutingNo;
    RoutingLine."Version Code" := '';
    RoutingLine."Operation No." := RoutingTemplateLine."Operation No.";
    RoutingLine.Validate(Type, RoutingLine.Type::"Work Center");
    RoutingLine.Validate("No.", RoutingTemplateLine."Work Center No.");
    if RoutingTemplateLine.Description <> '' then
      RoutingLine.Validate(Description, RoutingTemplateLine.Description);
    RoutingLine.Validate("Setup Time", RoutingTemplateLine."Setup Time");
    RoutingLine.Validate("Run Time", RoutingTemplateLine."Run Time");
    RoutingLine.Insert(true);
  end;

  local procedure CheckNotUsedByOpenProdOrder(RoutingNo: Code[20])
  var
    ProdOrderLine: Record "Prod. Order Line";
  begin
    ProdOrderLine.SetRange("Routing No.", RoutingNo);
    ProdOrderLine.SetFilter(Status, '<>%1', ProdOrderLine.Status::Finished);
    if not ProdOrderLine.IsEmpty() then
      Error(RoutingInUseErr, RoutingNo);
  end;
}
