codeunit 50129 "CCO Packaging Quote Mgt."
{
  var
    SpecNotReleasedErr: Label 'Packaging specification %1 has no finished item. Release the specification before you create a sales quote.', Comment = '%1 = Packaging Specification No.';
    CustomerMismatchErr: Label 'Cost sheet %1 is for customer %2, but sales quote %3 is for customer %4.', Comment = '%1 = Cost Sheet No., %2 = Customer No. of the cost sheet, %3 = Sales Quote No., %4 = Customer No. of the quote';

  /// <summary>
  /// Creates a standard sales quote with one line for the finished item of the costed specification,
  /// priced from the price ladder line of the chosen quantity.
  /// </summary>
  /// <param name="CostSheet">The calculated cost sheet. The created quote number is saved on it.</param>
  /// <param name="LadderQuantity">The quoted quantity. A ladder line is added when the quantity is not in the price ladder yet.</param>
  /// <param name="SalesHeader">Returns the created sales quote.</param>
  procedure CreateSalesQuote(var CostSheet: Record "CCO Packaging Cost Sheet"; LadderQuantity: Decimal; var SalesHeader: Record "Sales Header")
  begin
    CostSheet.TestField("Customer No.");
    CreateQuoteHeader(CostSheet."Customer No.", SalesHeader);
    AddQuoteLine(SalesHeader, CostSheet, LadderQuantity);
  end;

  /// <summary>
  /// Creates an empty standard sales quote for a customer.
  /// </summary>
  /// <param name="CustomerNo">The sell-to customer.</param>
  /// <param name="SalesHeader">Returns the created sales quote.</param>
  procedure CreateQuoteHeader(CustomerNo: Code[20]; var SalesHeader: Record "Sales Header")
  begin
    SalesHeader.Init();
    SalesHeader."Document Type" := SalesHeader."Document Type"::Quote;
    SalesHeader."No." := '';
    SalesHeader.Insert(true);
    SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
    SalesHeader.Modify(true);
  end;

  /// <summary>
  /// Adds a line for the finished item of the costed specification to a sales quote,
  /// priced from the price ladder line of the chosen quantity.
  /// </summary>
  /// <param name="SalesHeader">The sales quote. Its customer must match the cost sheet customer.</param>
  /// <param name="CostSheet">The calculated cost sheet. The quote number is saved on it.</param>
  /// <param name="LadderQuantity">The quoted quantity. A ladder line is added when the quantity is not in the price ladder yet.</param>
  procedure AddQuoteLine(SalesHeader: Record "Sales Header"; var CostSheet: Record "CCO Packaging Cost Sheet"; LadderQuantity: Decimal)
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
    CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";
  begin
    CostSheet.TestField("Customer No.");
    if CostSheet."Customer No." <> SalesHeader."Sell-to Customer No." then
      Error(CustomerMismatchErr, CostSheet."No.", CostSheet."Customer No.", SalesHeader."No.", SalesHeader."Sell-to Customer No.");

    PackagingSpecification.Get(CostSheet."Specification No.");
    if PackagingSpecification."Item No." = '' then
      Error(SpecNotReleasedErr, PackagingSpecification."No.");

    CostEngineMgt.FindOrAddLadderLine(CostSheet, LadderQuantity, CostSheetLine);
    CreateSalesLine(SalesHeader, PackagingSpecification, CostSheet, CostSheetLine);

    CostSheet."Sales Quote No." := SalesHeader."No.";
    CostSheet.Modify(true);
  end;

  local procedure CreateSalesLine(SalesHeader: Record "Sales Header"; PackagingSpecification: Record "CCO Packaging Specification"; CostSheet: Record "CCO Packaging Cost Sheet"; CostSheetLine: Record "CCO Packaging Cost Sheet Line")
  var
    SalesLine: Record "Sales Line";
  begin
    SalesLine.Init();
    SalesLine."Document Type" := SalesHeader."Document Type";
    SalesLine."Document No." := SalesHeader."No.";
    SalesLine."Line No." := GetNextLineNo(SalesHeader);
    SalesLine.Validate(Type, SalesLine.Type::Item);
    SalesLine.Validate("No.", PackagingSpecification."Item No.");
    SalesLine.Validate(Quantity, CostSheetLine.Quantity);
    // The calculated price already contains the margin, so standard prices and line discounts must not change it.
    SalesLine.Validate("Unit Price", GetDocumentUnitPrice(SalesHeader, SalesLine."VAT %", CostSheetLine."Unit Price"));
    SalesLine.Validate("Line Discount %", 0);
    SalesLine."CCO Packaging Spec. No." := PackagingSpecification."No.";
    SalesLine."CCO Cost Sheet No." := CostSheet."No.";
    SalesLine.Insert(true);
  end;

  local procedure GetNextLineNo(SalesHeader: Record "Sales Header") NextLineNo: Integer
  var
    SalesLine: Record "Sales Line";
  begin
    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
    SalesLine.SetRange("Document No.", SalesHeader."No.");
    if SalesLine.FindLast() then;
    NextLineNo := SalesLine."Line No." + 10000;
  end;

  local procedure GetDocumentUnitPrice(SalesHeader: Record "Sales Header"; VATPercent: Decimal; UnitPriceLCY: Decimal) UnitPrice: Decimal
  var
    Currency: Record Currency;
    CurrencyExchangeRate: Record "Currency Exchange Rate";
    CurrencyDate: Date;
  begin
    UnitPrice := UnitPriceLCY;
    if SalesHeader."Currency Code" <> '' then begin
      CurrencyDate := SalesHeader."Posting Date";
      if CurrencyDate = 0D then
        CurrencyDate := WorkDate();
      UnitPrice := CurrencyExchangeRate.ExchangeAmtLCYToFCY(CurrencyDate, SalesHeader."Currency Code", UnitPrice, SalesHeader."Currency Factor");
    end;

    if SalesHeader."Prices Including VAT" then
      UnitPrice := UnitPrice * (1 + VATPercent / 100);

    Currency.Initialize(SalesHeader."Currency Code");
    UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
  end;
}
