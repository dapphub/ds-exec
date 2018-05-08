{ solidityPackage, dappsys }: solidityPackage {
  name = "ds-exec";
  deps = with dappsys; [ds-test];
  src = ./src;
}
