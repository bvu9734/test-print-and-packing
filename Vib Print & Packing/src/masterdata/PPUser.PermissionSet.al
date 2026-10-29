permissionset 50117 "PP_USER"
{
  Assignable = true;
  Caption = 'Print and Packaging User';

  Permissions =
    tabledata "CCO Packaging Specification" = RIMD,
    tabledata "CCO Packaging Setup" = R,
    tabledata "No. Series" = R,
    tabledata Item = R,
    codeunit "No. Series" = X,
    page "CCO Packaging Specifications" = X,
    page "CCO Packaging Spec. Card" = X,
    page "Item List" = X,
    page "Item Card" = X;
}
