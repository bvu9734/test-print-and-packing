permissionset 50117 "PP_USER"
{
  Assignable = true;
  Caption = 'Print and Packaging User';

  Permissions =
    tabledata "CCO Packaging Specification" = RIMD,
    tabledata "CCO Packaging Setup" = R,
    tabledata "CCO Packaging Cost Sheet" = RIMD,
    tabledata "CCO Packaging Cost Sheet Line" = RIMD,
    tabledata "CCO Packaging Wksh. Name" = RIMD,
    tabledata "CCO Packaging Wksh. Line" = RIMD,
    tabledata "CCO Print Cost Matrix" = R,
    tabledata "No. Series" = R,
    tabledata "No. Series Line" = RM,
    tabledata Item = RIM,
    tabledata "Item Unit of Measure" = RIM,
    tabledata "Item Templ." = R,
    tabledata Customer = R,
    codeunit "No. Series" = X,
    codeunit "CCO Cost Engine Mgt." = X,
    codeunit "CCO Spec. Item Mgt." = X,
    codeunit "CCO Packaging Quote Mgt." = X,
    codeunit "CCO Packaging Wksh. Mgt." = X,
    page "CCO Packaging Specifications" = X,
    page "CCO Packaging Spec. Card" = X,
    page "CCO Packaging Cost Sheets" = X,
    page "CCO Packaging Cost Sheet" = X,
    page "CCO Cost Sheet Subform" = X,
    page "CCO Packaging Quote Wizard" = X,
    page "CCO Cost Sheet Ladder" = X,
    page "CCO Packaging Worksheet" = X,
    page "CCO Packaging Wksh. Names" = X,
    page "Item List" = X,
    page "Item Card" = X;
}
