# Smart Office Open — XDG desktop integration
# Registers smart-office-open as the default handler for office file types.
# Opens Google Drive native files (0-byte) in browser, regular files with OnlyOffice.
# The script itself is installed system-wide via modules/core/packages.nix.
{ ... }:

{
  xdg.desktopEntries.smart-office-open = {
    name = "Smart Office Open";
    comment = "Opens Google Drive files in browser, others with OnlyOffice";
    exec = "smart-office-open %f";
    terminal = false;
    type = "Application";
    categories = [ "Office" ];
    mimeType = [
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/msword"
      "application/vnd.ms-excel"
      "application/vnd.ms-powerpoint"
      "application/x-zerosize"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "smart-office-open.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "smart-office-open.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "smart-office-open.desktop";
      "application/msword" = "smart-office-open.desktop";
      "application/vnd.ms-excel" = "smart-office-open.desktop";
      "application/vnd.ms-powerpoint" = "smart-office-open.desktop";
      "application/x-zerosize" = "smart-office-open.desktop";
    };
  };
}
