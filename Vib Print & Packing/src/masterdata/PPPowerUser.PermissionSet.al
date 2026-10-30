permissionset 50118 "PP_POWERUSER"
{
  Assignable = true;
  Caption = 'Print and Packaging Power User';
  IncludedPermissionSets = "PP_USER";

  Permissions =
    tabledata "CCO Packaging Setup" = RIMD,
    tabledata "CCO Print Cost Matrix" = RIMD,
    tabledata "CCO Routing Template" = RIMD,
    tabledata "CCO Routing Template Line" = RIMD,
    tabledata Customer = RM,
    page "CCO Packaging Setup" = X,
    page "CCO Print Cost Matrix" = X,
    page "CCO Routing Templates" = X,
    page "CCO Routing Template" = X,
    page "CCO Routing Template Subform" = X,
    page "No. Series" = X,
    page "Customer Card" = X;
}
