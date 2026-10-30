table 50135 "CCO Packaging Wksh. Line"
{
  Caption = 'Packaging Worksheet Line';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "Worksheet Name"; Code[10])
    {
      Caption = 'Worksheet Name';
      ToolTip = 'Specifies the packaging worksheet batch that the line belongs to.', Comment = 'hu-HU=Megadja a csomagolási munkalap kötegét, amelyhez a sor tartozik.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Wksh. Name";
    }
    field(2; "Line No."; Integer)
    {
      Caption = 'Line No.';
      ToolTip = 'Specifies the number of the line.', Comment = 'hu-HU=Megadja a sor számát.';
      DataClassification = CustomerContent;
    }
    field(3; Accept; Boolean)
    {
      Caption = 'Accept';
      ToolTip = 'Specifies whether the line is included when you create sales quotes. Lines that are not accepted stay in the worksheet.', Comment = 'hu-HU=Megadja, hogy a sor bekerül-e az értékesítési árajánlatok létrehozásakor. A nem elfogadott sorok a munkalapon maradnak.';
      DataClassification = CustomerContent;
      InitValue = true;
    }
    field(4; "Customer No."; Code[20])
    {
      Caption = 'Customer No.';
      ToolTip = 'Specifies the customer to quote. Lines of the same customer are combined into one sales quote.', Comment = 'hu-HU=Megadja az árajánlat vevőjét. Az azonos vevőhöz tartozó sorok egy értékesítési árajánlatba kerülnek.';
      DataClassification = CustomerContent;
      TableRelation = Customer;

      trigger OnValidate()
      begin
        CheckSpecificationCustomer();
        UpdateCustomerName();
        RecalculateFromScratch();
      end;
    }
    field(5; "Customer Name"; Text[100])
    {
      Caption = 'Customer Name';
      ToolTip = 'Specifies the name of the customer.', Comment = 'hu-HU=Megadja a vevő nevét.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(6; "Specification No."; Code[20])
    {
      Caption = 'Specification No.';
      ToolTip = 'Specifies the released packaging specification to quote.', Comment = 'hu-HU=Megadja az árajánlatba adandó kiadott csomagolási specifikációt.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Specification" where(Status = const(Released));

      trigger OnValidate()
      var
        PackagingSpecification: Record "CCO Packaging Specification";
      begin
        Description := '';
        "Item No." := '';
        if "Specification No." <> '' then begin
          PackagingSpecification.Get("Specification No.");
          if (PackagingSpecification.Status <> PackagingSpecification.Status::Released) or (PackagingSpecification."Item No." = '') then
            Error(SpecificationNotReleasedErr, "Specification No.");
          if ("Customer No." = '') and (PackagingSpecification."Customer No." <> '') then begin
            "Customer No." := PackagingSpecification."Customer No.";
            UpdateCustomerName();
          end;
          CheckSpecificationCustomer();
          Description := PackagingSpecification.Description;
          "Item No." := PackagingSpecification."Item No.";
        end;
        RecalculateFromScratch();
      end;
    }
    field(7; Description; Text[100])
    {
      Caption = 'Description';
      ToolTip = 'Specifies the description of the packaging specification.', Comment = 'hu-HU=Megadja a csomagolási specifikáció leírását.';
      DataClassification = CustomerContent;
      Editable = false;
    }
    field(8; "Item No."; Code[20])
    {
      Caption = 'Item No.';
      ToolTip = 'Specifies the finished item that is quoted.', Comment = 'hu-HU=Megadja az árajánlatba kerülő késztermék cikket.';
      DataClassification = CustomerContent;
      TableRelation = Item;
      Editable = false;
    }
    field(9; Quantity; Decimal)
    {
      Caption = 'Quantity';
      ToolTip = 'Specifies the quantity to quote. The price is calculated as soon as the customer, specification, and quantity are filled in.', Comment = 'hu-HU=Megadja az árajánlatba adandó mennyiséget. Az ár kiszámítása megtörténik, amint a vevő, a specifikáció és a mennyiség ki van töltve.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;

      trigger OnValidate()
      var
        PackagingWkshMgt: Codeunit "CCO Packaging Wksh. Mgt.";
      begin
        PackagingWkshMgt.CalculateLine(Rec);
      end;
    }
    field(10; "Margin %"; Decimal)
    {
      Caption = 'Margin %';
      ToolTip = 'Specifies the markup percentage added to the unit cost. It defaults from the customer and can be changed for this line.', Comment = 'hu-HU=Megadja az egységköltségre felszámított árrés százalékát. Alapértéke a vevőtől származik, és soronként módosítható.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      MinValue = 0;

      trigger OnValidate()
      var
        PackagingWkshMgt: Codeunit "CCO Packaging Wksh. Mgt.";
      begin
        PackagingWkshMgt.CalculateLine(Rec);
      end;
    }
    field(11; "Unit Price (LCY)"; Decimal)
    {
      Caption = 'Unit Price (LCY)';
      ToolTip = 'Specifies the calculated unit price in local currency. It is rounded and converted to the currency of the customer on the quote.', Comment = 'hu-HU=Megadja a számított egységárat saját pénznemben. Az árajánlaton kerekítve és a vevő pénznemére átváltva jelenik meg.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(12; "Line Amount (LCY)"; Decimal)
    {
      Caption = 'Line Amount (LCY)';
      ToolTip = 'Specifies the calculated total price of the line in local currency.', Comment = 'hu-HU=Megadja a sor számított teljes árát saját pénznemben.';
      DataClassification = CustomerContent;
      DecimalPlaces = 0 : 5;
      Editable = false;
    }
    field(13; "Cost Sheet No."; Code[20])
    {
      Caption = 'Cost Sheet No.';
      ToolTip = 'Specifies the cost sheet that the price of the line is calculated on. It is kept with the sales quote.', Comment = 'hu-HU=Megadja a költséglapot, amelyen a sor árát kiszámították. Az értékesítési árajánlattal együtt megmarad.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Cost Sheet";
      Editable = false;
    }
  }

  keys
  {
    key(PK; "Worksheet Name", "Line No.")
    {
      Clustered = true;
    }
    key(Customer; "Worksheet Name", "Customer No.")
    {
    }
  }

  trigger OnDelete()
  var
    PackagingWkshMgt: Codeunit "CCO Packaging Wksh. Mgt.";
  begin
    PackagingWkshMgt.DeleteCostSheet(Rec);
  end;

  var
    SpecificationNotReleasedErr: Label 'Packaging specification %1 must be released before it can be quoted.', Comment = '%1 = Packaging Specification No.';
    SpecificationOtherCustomerErr: Label 'Packaging specification %1 belongs to customer %2.', Comment = '%1 = Packaging Specification No., %2 = Customer No.';

  local procedure CheckSpecificationCustomer()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
  begin
    if ("Specification No." = '') or ("Customer No." = '') then
      exit;
    PackagingSpecification.Get("Specification No.");
    if not (PackagingSpecification."Customer No." in ['', "Customer No."]) then
      Error(SpecificationOtherCustomerErr, "Specification No.", PackagingSpecification."Customer No.");
  end;

  local procedure UpdateCustomerName()
  var
    Customer: Record Customer;
  begin
    "Customer Name" := '';
    if Customer.Get("Customer No.") then
      "Customer Name" := Customer.Name;
  end;

  local procedure RecalculateFromScratch()
  var
    PackagingWkshMgt: Codeunit "CCO Packaging Wksh. Mgt.";
  begin
    PackagingWkshMgt.DeleteCostSheet(Rec);
    PackagingWkshMgt.CalculateLine(Rec);
  end;
}
