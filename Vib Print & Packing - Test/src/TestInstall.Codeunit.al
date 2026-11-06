codeunit 50299 "CCO Test Install"
{
  Subtype = Install;

  var
    TestSuiteNameTok: Label 'PRINTPACK', Locked = true, MaxLength = 10;
    // Codeunit 50205 "CCO Packaging Demo Data Tests" is skipped: it changes the company's demo master data.
    TestCodeunitRangeTok: Label '50200..50204|50206..50250', Locked = true;

  trigger OnInstallAppPerCompany()
  begin
    SetupTestSuite();
  end;

  local procedure SetupTestSuite()
  var
    ALTestSuite: Record "AL Test Suite";
    TestSuiteMgt: Codeunit "Test Suite Mgt.";
    TestSuiteName: Code[10];
  begin
    TestSuiteName := TestSuiteNameTok;
    if not ALTestSuite.Get(TestSuiteName) then begin
      TestSuiteMgt.CreateTestSuite(TestSuiteName);
      ALTestSuite.Get(TestSuiteName);
    end;

    TestSuiteMgt.DeleteAllMethods(ALTestSuite);
    TestSuiteMgt.SelectTestMethodsByRange(ALTestSuite, TestCodeunitRangeTok);
  end;
}
